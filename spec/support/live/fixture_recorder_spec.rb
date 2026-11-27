# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require_relative "fixture_recorder"

RSpec.describe Jira::Live::FixtureRecorder do
  include described_class

  let(:dir) { Dir.mktmpdir }
  let(:url) { "https://pinokio.atlassian.net/rest/api/3/issue/TEST-1/changelog/list" }
  let(:response_body) do
    {
      histories: [
        {
          id:     "10237",
          author: {
            self:         "https://pinokio.atlassian.net/rest/api/3/user?accountId=abc%3A123",
            accountId:    "abc:123",
            emailAddress: "real.person@corp.example",
            displayName:  "Real Person"
          }
        }
      ]
    }.to_json
  end

  after { FileUtils.remove_entry(dir) }

  def post_changelog_list
    HTTParty.post(url, body: { changelogIds: [10_237] }.to_json, headers: { "Content-Type" => "application/json" })
  end

  def record(name, &)
    record_fixture(
      name,
      real_only: false, dir: dir, host: "pinokio.atlassian.net",
            email: "real.person@corp.example",
      &
    )
  end

  it "writes the sanitized response body and the request body", :aggregate_failures do
    stub_request(:post, url).to_return(body: response_body, headers: { "Content-Type" => "application/json" })

    result = record("sample") { post_changelog_list }

    response_fixture = File.read(File.join(dir, "sample.json"))
    expect(response_fixture).not_to include(
      "real.person@corp.example",
      "abc:123",
      "abc%3A123",
      "Real Person",
      "pinokio"
    )
    expect(JSON.parse(File.read(File.join(dir, "sample_request.json")))).to eq("changelogIds" => [10_237])
    expect(result.code).to eq(200)
  end

  it "skips the request fixture when the request has no JSON body" do
    stub_request(
      :get,
      "https://pinokio.atlassian.net/rest/api/3/myself"
    ).to_return(body: { accountId: "abc:123" }.to_json)

    record("myself") { HTTParty.get("https://pinokio.atlassian.net/rest/api/3/myself") }

    expect(File).not_to exist(File.join(dir, "myself_request.json"))
  end

  it "raises when no request was made inside the block" do
    expect { record("nothing") { nil } }.to raise_error(described_class::NothingRecordedError)
  end
end
