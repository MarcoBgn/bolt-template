# frozen_string_literal: true
# Abstract base class inherited by all the layouts
class Layouts::Base < ApplicationModel
  attr_accessor :name

  def initialize
    self.name = self.class.to_s.demodulize.underscore
  end

  def render
    as_json.except('name')
  end
end
