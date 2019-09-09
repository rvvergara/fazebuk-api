# frozen_string_literal: true

module ApplicationHelper
  def convert_to_i(date)
    date.to_time.to_i
  end
end
