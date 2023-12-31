require_relative "sf_connect/version"
require "active_support/all"

#
# salesforce connective object
#
module SfConnect
  extend ActiveSupport::Autoload
  autoload :Define
  autoload :Payload
  autoload :Fields
  autoload :Uploader
  autoload :Downloader

  class << self
    def define(salesforce_object_name, where: nil, **fields, &)
      SfConnect::Define.new(salesforce_object_name, where:, fields:, &).call
    end

    def connect
      yield Restforce.new
    end

    def query(soql)
      connect { |restforce| restforce.query(soql) }
    end

    def find(salesforce_object_name, id, field)
      connect { |restforce| restforce.find(salesforce_object_name, id, field) }
    end

    def create!(salesforce_object_name, payload)
      connect do |restforce|
        restforce.create!(
          salesforce_object_name, payload
        )
      end
    end

    def update!(salesforce_object_name, id, payload)
      connect do |restforce|
        restforce.update!(
          salesforce_object_name, { Id: id, **payload }
        )
      end
    end
  end
end
