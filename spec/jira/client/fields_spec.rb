# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".fields" do
    it "returns all fields", :aggregate_failures do
      stub_get("/field", "fields.json")

      result = Jira.fields

      expect(a_get("/field")).to have_been_made
      expect(result.size).to eq(2)
      expect(result.last[:id]).to eq("customfield_10001")
    end
  end

  describe ".field_search" do
    it "returns a paginated page of fields", :aggregate_failures do
      stub_get("/field/search?type=custom", "field_search.json")

      result = Jira.field_search(type: "custom")

      expect(a_get("/field/search?type=custom")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.first[:name]).to eq("Story Points")
    end
  end

  describe ".issue_types" do
    it "returns all issue types" do
      stub_get("/issuetype", "issue_types.json")

      expect(Jira.issue_types.map { |t| t[:name] }).to eq(%w[Task Bug])
    end
  end

  describe ".priorities" do
    it "returns all priorities" do
      stub_get("/priority", "priorities.json")

      expect(Jira.priorities.first[:name]).to eq("Highest")
    end
  end

  describe ".statuses" do
    it "returns all statuses" do
      stub_get("/status", "statuses.json")

      expect(Jira.statuses.map { |s| s.dig(:statusCategory, :key) }).to eq(%w[new indeterminate])
    end
  end

  describe ".resolutions" do
    it "returns all resolutions" do
      stub_get("/resolution", "resolutions.json")

      expect(Jira.resolutions.last[:name]).to eq("Won't Do")
    end
  end

  describe ".labels" do
    it "returns labels as a paginated response", :aggregate_failures do
      stub_get("/label?maxResults=1000", "labels.json")

      result = Jira.labels(maxResults: 1000)

      expect(a_get("/label?maxResults=1000")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(2)
    end
  end
end
