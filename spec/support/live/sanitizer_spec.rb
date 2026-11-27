# frozen_string_literal: true

require "spec_helper"
require_relative "sanitizer"

RSpec.describe Jira::Live::Sanitizer do
  let(:account_id) { "712020:1a2b3c4d-0000-1111-2222-333344445555" }
  let(:payload) do
    {
      "self" => "https://pinokio.atlassian.net/rest/api/3/user?accountId=#{URI.encode_www_form_component(account_id)}",
      "accountId" => account_id,
      "emailAddress" => "real.person@corp.example",
      "displayName" => "Real Person",
      "avatarUrls" => { "48x48" => "https://avatar" },
      "groups" => {
        "items" => [
          { "name" => "jira-users-pinokio", "self" => "https://pinokio.atlassian.net/rest/api/3/group?groupId=1" }
        ]
      },
      "records" => [{ "authorAccountId" => "other:999", "authorKey" => "ug:legacy-key",
"remoteAddress" => "10.1.2.3" }],
      "description" => "Contact real.person@corp.example"
    }
  end

  let(:result) { described_class.call(payload, host: "pinokio.atlassian.net", email: "real.person@corp.example") }
  let(:serialized) { JSON.generate(result) }

  it "removes the original email, host, account IDs, names and IPs", :aggregate_failures do
    expect(serialized).not_to include("real.person@corp.example", "pinokio.atlassian.net", account_id)
    expect(serialized).not_to include(URI.encode_www_form_component(account_id), "Real Person", "10.1.2.3", "other:999")
    expect(serialized).not_to include("ug:legacy-key", "pinokio")
  end

  it "replaces values with stable placeholders", :aggregate_failures do
    expect(result["accountId"]).to eq(described_class::FAKE_ACCOUNT_ID)
    expect(result["emailAddress"]).to eq(described_class::FAKE_EMAIL)
    expect(result["displayName"]).to eq(described_class::FAKE_DISPLAY_NAME)
    expect(result["self"]).to eq("https://example.atlassian.net/rest/api/3/user?accountId=#{described_class::FAKE_ACCOUNT_ID}")
  end

  it "drops avatar URLs and keeps unrelated data", :aggregate_failures do
    expect(result).not_to have_key("avatarUrls")
    expect(result.dig("groups", "items", 0, "name")).to eq("jira-users-example")
  end

  it "accepts a missing host and email" do
    expect(described_class.call({ "key" => "TEST-1" }, host: nil, email: nil)).to eq("key" => "TEST-1")
  end
end
