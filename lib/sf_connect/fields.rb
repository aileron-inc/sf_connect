module SfConnect
  #
  # salesforce fields <=> object attributes
  #
  class Fields
    attr_reader :salesforce_object_name

    def initialize(salesforce_object_name:, where:, fields:, block:)
      @fields = fields
      @salesforce_object_name = salesforce_object_name
      @query = "select #{fields.keys.join(",")} from #{salesforce_object_name}"
      @query = "#{@query} where #{where}" if where

      @payload = Class.new(SfConnect::Payload)
      @payload.include(Module.new(&block)) if block
    end

    def fetch(id, field = nil)
      payload_for_download(SfConnect.find(salesforce_object_name, id, field))
    end

    def fetch_all(query_option)
      SfConnect.query(@query + query_option).each do |sobject|
        yield payload_for_download(sobject)
      end
    end

    def payload_for_upload_from_hash(record)
      @payload.new(record:, for_upload: convert_to_salesforce_from_hash(record)).for_upload
    end

    def payload_for_upload(record)
      @payload.new(record:, for_upload: convert_to_salesforce(record)).for_upload
    end

    def payload_for_download(record)
      @payload.new(record:, for_download: convert_from_salesforce(record))
    end

    private

    def convert(&)
      @fields.compact.filter_map(&).to_h
    end

    def convert_to_salesforce_from_hash(target)
      convert do |saeslforce_field_name, object_field_name|
        [
          saeslforce_field_name,
          target[object_field_name]
        ]
      end
    end

    def convert_to_salesforce(target)
      convert do |saeslforce_field_name, object_field_name|
        [
          saeslforce_field_name,
          target.try(object_field_name)
        ]
      end
    end

    def convert_from_salesforce(target)
      convert do |saeslforce_field_name, object_field_name|
        [
          object_field_name,
          target.try(saeslforce_field_name)
        ]
      end
    end
  end
end
