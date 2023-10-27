module SfConnect
  # payload for salesforce
  class Payload
    attr_reader :record, :for_upload, :for_download

    def initialize(record:, for_upload: nil, for_download: nil)
      @record = record
      @for_upload = for_upload
      @for_download = for_download
    end
  end
end
