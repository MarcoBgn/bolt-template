# frozen_string_literal: true
# Render a widget as a table, with labels and series
class Layouts::GroupedTable < Layouts::Base
  attr_accessor :title, :headers, :groups

  def initialize
    self.headers = []
    self.groups = []
    super
  end
end
