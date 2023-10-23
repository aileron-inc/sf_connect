module SfConnect
  #
  # upload salesforce object attribute
  #
  module Uploader
    extend ActiveSupport::Concern

    def upload_to_salesforce
      self.class.update_salesforce_attributes(salesforce_object_id, upload_payload_for_salesforce)
    end

    def upload_payload_for_salesforce
      self.class.salesforce_fields.convert_to_salesforce(self)
    end

    class_methods do
      def upload_salesforce_record(**attributes)
        create_salesforce_record(
          salesforce_fields.convert_to_salesforce_from_hash(attributes)
        )
      end

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
