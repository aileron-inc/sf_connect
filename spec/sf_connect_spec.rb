require "active_support/all"
require "active_model"

RSpec.describe SfConnect do
  let(:target_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes
      include SfConnect.define(
        :Contact,
        Email: :email,
        LastName: :last_name,
        FirstName: :first_name
      )
      attribute :email
      attribute :last_name
      attribute :first_name
    end
  end

  it "has a version number" do
    expect(SfConnect::VERSION).not_to be_nil
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
