# frozen_string_literal: true
# Render a widget as a chart, with labels and series
class Layouts::Chart < Layouts::Base
  attr_accessor :series

  def initialize
    self.series = []
    super
  end

  def add_series(series_hash)
    series << series_hash
  end
end
