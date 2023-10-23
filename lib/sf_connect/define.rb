module SfConnect
  #
  # define to salesforce connective module
  #
  class Define
    attr_reader :salesforce_object_name, :fields

    def initialize(salesforce_object_name, fields:, where: nil, &block)
      @salesforce_object_name = salesforce_object_name
      @define = generate_binding
      @define.include(SfConnect::Downloader)
      @define.include(SfConnect::Uploader)
      @fields = SfConnect::Fields.new(fields:, where:, salesforce_object_name:, block:)
    end

    def call
      @define
    end

    def generate_binding
      define = self
      Module.new do
        extend ActiveSupport::Concern
        class_methods do
          define_method(:salesforce_object_name) { define.salesforce_object_name }
          define_method(:salesforce_fields) { define.fields }
        end
      end
    end
  end
end
