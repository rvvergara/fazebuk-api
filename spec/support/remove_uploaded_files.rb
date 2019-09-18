# frozen_string_literal: true

module Helpers
  module RemoveUploadedFiles
    def remove_uploaded_files
      FileUtils.rm_rf(Rails.root.join('tmp', 'storage'))
    end
  end
end
