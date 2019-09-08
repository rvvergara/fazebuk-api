# frozen_string_literal: true

class Pagination
  def self.page(page_param)
    page_param || '1'
  end

  def self.set_max_in_page(page, record_count, records_per_page)
    page <= max_page(record_count, records_per_page)
  end

  def self.max_page(count, records_per_page)
    (count / records_per_page.to_f).ceil
  end

  def self.offset(page, per_page)
    (page.to_i - 1) * per_page
  end
end
