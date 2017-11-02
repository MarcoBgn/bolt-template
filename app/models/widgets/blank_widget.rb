# frozen_string_literal: true
# EXAMPLE
class Widgets::BlankWidget < Widgets::Base
  include Data::Local::Requester

  # SUPPORTED_LAYOUTS = %w(chart).freeze # chart is an example, add any layout used by widget
  #
  # def compute
  #   # calculates and fetches report
  #   self
  # end
  #
  # private
  #
  # # add fill function for all supported layouts based on layout class
  # def fill_chart(layout)
  #     layout.add_series(name: 'I am a series')
  # end
end
