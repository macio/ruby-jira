# frozen_string_literal: true

require "live_helper"

RSpec.describe Jira::Client do
  describe ".workflows" do
    it "returns workflows as a paginated response", :aggregate_failures do
      result = record_fixture("workflow_search") { Jira.workflows(maxResults: 5) }

      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.first.dig(:id, :name)).to be_a(String)
    end
  end
end
