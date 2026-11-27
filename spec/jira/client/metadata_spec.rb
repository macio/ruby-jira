# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".create_metadata" do
    it "returns create-screen metadata for a project's issue types", :aggregate_failures do
      stub_get("/issue/createmeta/ED/issuetypes", "create_metadata.json")

      result = Jira.create_metadata("ED")

      expect(a_get("/issue/createmeta/ED/issuetypes")).to have_been_made
      expected = fixture_json("create_metadata")["issueTypes"].map { |type| type["name"] }
      expect(result.map { |type| type[:name] }).to eq(expected)
    end
  end

  describe ".create_metadata_for_issue_type" do
    it "returns create-screen field metadata for one issue type", :aggregate_failures do
      stub_get("/issue/createmeta/ED/issuetypes/10001", "create_metadata_for_issue_type.json")

      result = Jira.create_metadata_for_issue_type("ED", 10_001)

      expect(a_get("/issue/createmeta/ED/issuetypes/10001")).to have_been_made
      fields = fixture_json("create_metadata_for_issue_type")["fields"]
      expect(result.map { |field| field[:fieldId] }).to eq(fields.map { |f| f["fieldId"] })
      expect(result.total).to eq(fields.size)
    end
  end
end
