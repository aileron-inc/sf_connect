module SfConnect
  #
  # upload salesforce object attribute
  #
  module Uploader
    extend ActiveSupport::Concern

    def upload_to_salesforce
      update_salesforce_attributes(upload_payload_for_salesforce)
    end

    def upload_payload_for_salesforce
      self.class.salesforce_fields.compact.transform_values do |field_name|
        try(field_name)
      end
    end

    def update_salesforce_attributes(payload)
      self.class.update_salesforce_attributes(salesforce_object_id, payload)
    end

    class_methods do
      def create_salesforce_record(payload)
        SfConnect.create!(salesforce_object_name, payload)
      end

      def update_salesforce_attributes(id, payload)
        SfConnect.update!(
          salesforce_object_name,
          id,
          payload
        )
      end
    end
  end
end
