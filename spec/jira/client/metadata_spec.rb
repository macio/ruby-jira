# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".create_metadata" do
    it "returns create-screen metadata for a project's issue types", :aggregate_failures do
      stub_get("/issue/createmeta/ED/issuetypes", "create_metadata.json")

      result = Jira.create_metadata("ED")

      expect(a_get("/issue/createmeta/ED/issuetypes")).to have_been_made
      expect(result.first[:fieldId]).to eq("summary")
      expect(result.first[:required]).to be(true)
    end
  end

  describe ".create_metadata_for_issue_type" do
    it "returns create-screen metadata for one issue type", :aggregate_failures do
      stub_get("/issue/createmeta/ED/issuetypes/10001", "create_metadata.json")

      result = Jira.create_metadata_for_issue_type("ED", 10_001)

      expect(a_get("/issue/createmeta/ED/issuetypes/10001")).to have_been_made
      expect(result.total).to eq(1)
    end
  end
end
