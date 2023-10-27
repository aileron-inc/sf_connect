RSpec.describe SfConnect do
  let(:target_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes
      include(SfConnect.define(
        :Contact,
        Email: :email,
        LastName: :last_name,
        FirstName: :first_name,
        Name: :name
      ) do
        def for_upload
          super.except(:Name)
        end
      end)
      attribute :name
      attribute :id
      attribute :email
      attribute :last_name
      attribute :first_name

      def salesforce_object_id
        id
      end
    end
  end

  let(:target) do
    target_class.new(
      id: "003RC000002CVYLYA4",
      email: "sf_connect@example.com",
      last_name: "Doe",
      first_name: "John"
    )
  end

  let(:sf_contact) do
    Restforce::SObject.new(
      "attributes" => { "type" => "Contact", "url" => "/services/data/v57.0/sobjects/Contact/003RC000002CVYLYA4" },
      "Id" => "003RC000002CVYLYA4",
      "IsDeleted" => false,
      "MasterRecordId" => nil,
      "AccountId" => "001RC000002SiucYAC",
      "Email" => "sf_connect@example.com",
      "LastName" => "Doe",
      "FirstName" => "John",
      "Name" => "John Doe"
    )
  end

  it "has a version number" do
    expect(SfConnect::VERSION).not_to be_nil
  end

  specify ".find_or_initialize_from_salesforce" do
    allow(target_class).to receive(:find_or_initialize_by)
    target_class.find_or_initialize_from_salesforce(id: "TEST")
    expect(target_class).to have_received(:find_or_initialize_by).with(id: "TEST")
  end

  specify ".fetch" do
    allow(SfConnect).to receive(:find)
    target_class.fetch("TEST")
    expect(SfConnect).to have_received(:find).with(:Contact, "TEST", nil)
  end

  specify ".fetch with field" do
    allow(SfConnect).to receive(:find)
    target_class.fetch("TEST", "Name")
    expect(SfConnect).to have_received(:find).with(:Contact, "TEST", "Name")
  end

  specify ".fetch_all" do
    allow(SfConnect).to receive(:query).and_return([sf_contact])
    target_class.fetch_all { _1 }
    expect(SfConnect).to have_received(:query).with("select Email,LastName,FirstName,Name from Contact")
  end

  specify ".download_salesforce_records" do
    allow(SfConnect).to receive(:query).and_return([sf_contact])
    allow(target_class).to receive(:upsert_all)
    target_class.download_salesforce_records
    expect(target_class).to have_received(:upsert_all).with(
      [
        {
          email: "sf_connect@example.com",
          first_name: "John",
          last_name: "Doe",
          name: "John Doe"
        }
      ]
    )
  end

  specify ".download_salesforce_record" do
    allow(target_class).to receive(:find_or_initialize_by).and_return(target)
    allow(target).to receive(:update)
    allow(SfConnect).to receive(:find).and_return(sf_contact)
    target_class.download_salesforce_record("003RC000002CVYLYA4")
    expect(SfConnect).to have_received(:find).with(
      :Contact,
      "003RC000002CVYLYA4",
      nil
    )
  end

  specify ".update_salesforce_attributes" do
    allow(SfConnect).to receive(:update!)
    target_class.update_salesforce_attributes("TEST", Email: "sf_connect+1@example.com")
    expect(SfConnect).to have_received(:update!).with(
      :Contact,
      "TEST",
      Email: "sf_connect+1@example.com"
    )
  end

  specify ".create_salesforce_record" do
    allow(SfConnect).to receive(:create!)
    target_class.create_salesforce_record(Email: "sf_connect+1@example.com")
    expect(SfConnect).to have_received(:create!).with(
      :Contact,
      Email: "sf_connect+1@example.com"
    )
  end

  specify ".upload_salesforce_record" do
    allow(SfConnect).to receive(:create!)
    target_class.upload_salesforce_record(email: "sf_connect+1@example.com")
    expect(SfConnect).to have_received(:create!).with(
      :Contact,
      Email: "sf_connect+1@example.com",
      LastName: nil,
      FirstName: nil
    )
  end

  specify "#fetch" do
    allow(SfConnect).to receive(:find).and_return(sf_contact)
    target.fetch
    expect(SfConnect).to have_received(:find).with(
      :Contact,
      "003RC000002CVYLYA4",
      nil
    )
  end

  specify "#download_from_salesforce" do
    allow(SfConnect).to receive(:find).and_return(sf_contact)
    allow(target_class).to receive(:find_or_initialize_by).and_return(target)
    allow(target).to receive(:update)
    target.download_from_salesforce
    expect(SfConnect).to have_received(:find).with(
      :Contact,
      "003RC000002CVYLYA4",
      nil
    )
  end

  specify "#upload_to_salesforce" do
    allow(SfConnect).to receive(:update!)
    target.upload_to_salesforce
    expect(SfConnect).to have_received(:update!).with(
      :Contact,
      "003RC000002CVYLYA4",
      Email: "sf_connect@example.com",
      LastName: "Doe",
      FirstName: "John"
    )
  end

  specify "#upload_payload_for_salesforce" do
    expect(
      target_class.new(
        email: "sf_connect@example.com",
        first_name: "John",
        last_name: "Doe"
      ).upload_payload_for_salesforce
    ).to eq(
      Email: "sf_connect@example.com",
      FirstName: "John",
      LastName: "Doe"
    )
  end
end
