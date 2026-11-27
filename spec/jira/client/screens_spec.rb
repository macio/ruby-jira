# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".screens" do
    it "returns screens as a paginated response", :aggregate_failures do
      stub_get("/screens", "screens.json")

      result = Jira.screens

      expect(a_get("/screens")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.first[:name]).to eq("Default screen")
    end
  end
end
