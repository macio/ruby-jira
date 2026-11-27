# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".workflows" do
    it "returns workflows as a paginated response", :aggregate_failures do
      stub_get("/workflow/search?maxResults=50", "workflow_search.json")

      result = Jira.workflows(maxResults: 50)

      expect(a_get("/workflow/search?maxResults=50")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.first[:isDefault]).to be(true)
    end
  end
end
