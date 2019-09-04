# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def offset(page, per_page)
    (page.to_i - 1) * per_page
  end
end
