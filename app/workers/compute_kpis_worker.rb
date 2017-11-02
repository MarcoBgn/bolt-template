# frozen_string_literal: true
# Compute KPIs attached to an organization's dashboards and widgets,
# -- depending on a list of updated entities
class ComputeKpisWorker < ApplicationWorker
  queue_as :kpis

  BATCH_PERIOD = (ENV['KPIS_BATCH_PERIOD'] || '60').to_i.seconds

  # TODO: make use of updated_entities
  def perform(channel_id)
    return retry_job(wait: BATCH_PERIOD) unless can_execute?(channel_id)

    Rails.logger.info "channel_id=#{channel_id}, action=compute-kpis | Computing..."

    all_kpis = fetch_kpis_list(channel_id)
    all_kpis.each do |kpi_hash|
      kpi_class = Kpis::Base::KPIS_LIST[kpi_hash['endpoint']]&.constantize
      next unless kpi_class.present? && kpi_hash['settings'].present? && kpi_hash['alerts'].present?

      # Filter out the kpis hashes that don't have alerts with recipients
      recipients_array = kpi_hash['alerts'].map { |a| a['recipients'] }.flatten.compact.uniq
      next unless recipients_array.present?

      kpi = kpi_class.new(kpi_hash)
      kpi.dispatch_alerts
    end
  end

  # Starts batching the execution of the worker for a given channel_id
  # updated_entities_names will be collected every time this method is called:
  # -- batch_for('org-fbba', ['invoices', 'journals']) => batch for 'org-fbba' with ['invoices', 'journals']
  # -- batch_for('org-fbba', ['account']) => batch for 'org-fbba' with ['invoices', 'journals', 'accounts']
  # -- batch_for('org-fbba', ['invoices']) => batch for 'org-fbba' with ['invoices', 'journals', 'accounts', 'invoices']
  def self.batch_for(channel_id, updated_entities)
    key = cache_key(channel_id)

    # Bumps the queuing timer and adds the updated entities to the batch
    # TODO: when we make use of the entities list, use :uniq
    is_batched = REDIS_POOL.with do |redis|
      redis.multi do
        redis.get("#{key}/enqueue_until")
        redis.set("#{key}/enqueue_until", Time.zone.now + BATCH_PERIOD, ex: 2 * BATCH_PERIOD.to_i)
        redis.rpush("#{key}/entities", updated_entities)
      end.first.present?
    end

    # Enqueues the worker if not done already
    set(wait: BATCH_PERIOD).perform_later(channel_id) unless is_batched
  end

  def self.cache_key(channel_id)
    "workers/compute_kpis/#{channel_id}"
  end

  private

  # Verifies if the worker is allowed to be executed, and deletes the batch_attrs cache if so
  def can_execute?(channel_id)
    REDIS_POOL.with do |redis|
      key = self.class.cache_key(channel_id)
      queuing_timer = Chronic.parse redis.get("#{key}/enqueue_until")

      if queuing_timer.present? && queuing_timer >= Time.zone.now
        Rails.logger.info "channel_id=#{channel_id}, action=compute-kpis |" \
          " KPIs computation delayed until #{queuing_timer}"
        return false
      end

      # No batch set or timer is passed:
      # - wipe the cached
      # - execute the worker
      redis.multi do
        redis.del("#{key}/enqueue_until")
        redis.del("#{key}/entities")
      end
      true
    end
  end

  # Retrieves KPIs from MnoHub for the given organization
  def fetch_kpis_list(channel_id)
    mnohub_response = Clients::MnoHub.get_kpis(channel_id)
    if mnohub_response&.success?
      mnohub_response.parsed_response['data']
    else
      Rails.logger.warn "channel_id=#{channel_id}, " \
        'action=compute-kpis/fetch-kpis-list, ' \
        "status=#{mnohub_response&.code}, body=#{mnohub_response&.body}"
      []
    end
  end
end
