module SfConnect
  #
  # download salesforce objects
  #
  module Downloader
    extend ActiveSupport::Concern

    def download_from_salesforce
      fetch.update
    end

    def fetch
      self.class.fetch(salesforce_object_id)
    end

    class_methods do
      def find_or_initialize_from_salesforce(binding_attributes)
        find_or_initialize_by(id: binding_attributes[:id])
      end

      def fetch(id, field = nil)
        salesforce_download_record(
          SfConnect.find(salesforce_object_name, id, field)
        )
      end

      def fetch_all(query = "")
        return enum_for(:fetch_all, query) unless block_given?

        SfConnect.query(salesforce_query + query).each do |sobject|
          yield salesforce_download_record(sobject)
        end
      end

      def download_salesforce_records(batch_size = 1000)
        fetch_all.each_slice(batch_size) do |records|
          upsert_all records.map(&:binding_attributes)
        end
      end
    end
  end
end
