module SfConnect
  #
  # define to salesforce connective module
  #
  class Define
    attr_reader :salesforce_object_name, :where, :fields, :record_class, :query

    def initialize(salesforce_object_name, fields:, where: nil, &)
      @salesforce_object_name = salesforce_object_name
      @where = where
      @fields = fields
      @query = "select #{fields.keys.join(",")} from #{salesforce_object_name}"
      @query = "#{@query} where #{where}" if where
      @record_class = Class.new(SfConnect::DownloadRecord)
      @record_class.include(Module.new(&)) if block_given?
    end

    def call
      object = generate_binding
      object.include(SfConnect::Downloader)
      object.include(SfConnect::Uploader)
      object
    end

    def generate_binding
      define = self
      Module.new do
        extend ActiveSupport::Concern
        class_methods do
          define_method(:salesforce_download_record) { |sfobject| define.record_class.new(self, sfobject) }
          define_method(:salesforce_object_name) { define.salesforce_object_name }
          define_method(:salesforce_fields) { define.fields }
          define_method(:salesforce_query) { define.query }
        end
      end
    end
  end
end
