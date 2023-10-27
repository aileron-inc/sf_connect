module SfConnect
  #
  # download salesforce objects
  #
  module Downloader
    extend ActiveSupport::Concern

    def fetch
      self.class.fetch(salesforce_object_id)
    end

    def download_from_salesforce
      self.class.download_salesforce_record(salesforce_object_id)
    end

    class_methods do
      def find_or_initialize_from_salesforce(binding_attributes)
        find_or_initialize_by(id: binding_attributes[:id])
      end

      def fetch(id, field = nil)
        salesforce_fields.fetch(id, field)
      end

      def fetch_all(query = "", &)
        return enum_for(:fetch_all, query) unless block_given?

        salesforce_fields.fetch_all(query, &)
      end

      def download_salesforce_record(salesforce_object_id)
        payload = fetch(salesforce_object_id)
        record = find_or_initialize_from_salesforce(payload.for_download)
        record.update(payload.for_download)
        record
      end

      def import_records_for_salesforce(records)
        upsert_all records
      end

      def download_salesforce_records(batch_size = 1000)
        fetch_all.each_slice(batch_size) do |records|
          import_records_for_salesforce records.map(&:for_download)
        end
      end
    end
  end
end
