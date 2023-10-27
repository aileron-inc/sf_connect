require_relative "sf_connect/version"
require "active_support/all"

#
# salesforce connective object
#
module SfConnect
  extend ActiveSupport::Autoload
  autoload :Define
  autoload :Fields
  autoload :Uploader
  autoload :Downloader

  # upload and download payload
  Payload = Struct.new(:record, :for_upload, :for_download, keyword_init: true)

  class << self
    def define(salesforce_object_name, where: nil, **fields, &)
      SfConnect::Define.new(salesforce_object_name, where:, fields:, &).call
    end

    def query(soql)
      Restforce.new.query(soql)
    end

    def find(salesforce_object_name, id, field)
      Restforce.new.find(salesforce_object_name, id, field)
    end

    def create!(salesforce_object_name, payload)
      Restforce.new.create!(
        salesforce_object_name, payload
      )
    end

    def update!(salesforce_object_name, id, payload)
      Restforce.new.update!(
        salesforce_object_name, { Id: id, **payload }
      )
    end
  end
end
