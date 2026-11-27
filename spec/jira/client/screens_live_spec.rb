# frozen_string_literal: true

require "live_helper"

RSpec.describe Jira::Client do
  describe ".screens" do
    it "returns screens as a paginated response", :aggregate_failures do
      result = record_fixture("screens") { Jira.screens(maxResults: 5) }

      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.first[:name]).to be_a(String)
    end
  end
end
