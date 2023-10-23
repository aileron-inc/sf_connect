module SfConnect
  #
  # salesforce fields <=> object attributes
  #
  class Fields
    attr_reader :salesforce_object_name, :query, :fields, :result_class

    def initialize(salesforce_object_name:, where:, fields:, block:)
      @fields = fields
      @salesforce_object_name = salesforce_object_name
      @query = "select #{fields.keys.join(",")} from #{salesforce_object_name}"
      @query = "#{@query} where #{where}" if where

      @result_class = Class.new(SfConnect::Result)
      @result_class.include(Module.new(&block)) if block
    end

    def fetch(id, field = nil)
      result(SfConnect.find(salesforce_object_name, id, field))
    end

    def fetch_all(query_option)
      SfConnect.query(query + query_option).each do |sobject|
        yield result(sobject)
      end
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

    private

    def result(record)
      result_class.new(record:, binding_attributes: convert_from_salesforce(record))
    end

    def convert(&)
      @fields.compact.filter_map(&).to_h
    end
  end
end
