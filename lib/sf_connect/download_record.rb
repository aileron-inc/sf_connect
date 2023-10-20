module SfConnect
  #
  # salesforce object binding
  #
  class DownloadRecord
    attr_reader :model, :record, :binding_attributes

    def initialize(model, record)
      @model = model
      @record = record
      @binding_attributes = model.salesforce_fields.filter_map { |from, to| [to, record[from.to_s]] if to }.to_h
    end

    def salesforce_object_id
      @binding_attributes[:id]
    end

    def download
      result = model.find_or_initialize_from_salesforce(binding_attributes)
      result.update(binding_attributes)
      result
    end
  end
end
