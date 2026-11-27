# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  let(:payload) do
    {
      type:         { name: "Blocks" },
      inwardIssue:  { key: "TEST-2" },
      outwardIssue: { key: "TEST-1" }
    }
  end

  describe ".create_issue_link" do
    it "posts the link payload and accepts an empty 201 response", :aggregate_failures do
      stub_request(:post, "#{Jira.endpoint}/rest/api/3/issueLink")
        .with(body: payload.to_json)
        .to_return(status: 201, body: "")

      Jira.create_issue_link(payload)

      expect(
        a_request(:post, "#{Jira.endpoint}/rest/api/3/issueLink")
                .with(body: payload.to_json)
      ).to have_been_made
    end
  end

  describe ".issue_link" do
    it "returns a link by ID", :aggregate_failures do
      stub_get("/issueLink/10000", "issue_link.json")

      result = Jira.issue_link(10_000)

      expect(a_get("/issueLink/10000")).to have_been_made
      expected = fixture_json("issue_link")
      expect(result[:type][:name]).to eq(expected["type"]["name"])
      expect(result.outwardIssue[:key]).to eq(expected["outwardIssue"]["key"])
    end
  end

  describe ".delete_issue_link" do
    it "deletes a link" do
      stub_request(:delete, "#{Jira.endpoint}/rest/api/3/issueLink/10000")
        .with(headers: { "Authorization" => basic_authorization_value })
        .to_return(status: 204, body: "")

      Jira.delete_issue_link(10_000)

      expect(a_request(:delete, "#{Jira.endpoint}/rest/api/3/issueLink/10000")).to have_been_made
    end
  end

  describe ".issue_link_types" do
    it "returns link types under the issueLinkTypes key", :aggregate_failures do
      stub_get("/issueLinkType", "issue_link_types.json")

      result = Jira.issue_link_types

      expect(a_get("/issueLinkType")).to have_been_made
      expected = fixture_json("issue_link_types")["issueLinkTypes"].map { |type| type["name"] }
      expect(result[:issueLinkTypes].map { |t| t[:name] }).to eq(expected)
    end
  end
end
