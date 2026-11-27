# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".fields" do
    it "returns all fields", :aggregate_failures do
      stub_get("/field", "fields.json")

      result = Jira.fields

      expect(a_get("/field")).to have_been_made
      expect(result.size).to eq(fixture_json("fields").size)
      expect(result.map { |field| field[:id] }).to include("summary")
    end
  end

  describe ".field_search" do
    it "returns a paginated page of fields", :aggregate_failures do
      stub_get("/field/search?type=custom", "field_search.json")

      result = Jira.field_search(type: "custom")

      expect(a_get("/field/search?type=custom")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.first[:id]).to eq(fixture_json("field_search")["values"].first["id"])
    end
  end

  describe ".issue_types" do
    it "returns all issue types" do
      stub_get("/issuetype", "issue_types.json")

      expect(Jira.issue_types.map { |t| t[:name] }).to eq(fixture_json("issue_types").map { |t| t["name"] })
    end
  end

  describe ".priorities" do
    it "returns all priorities" do
      stub_get("/priority", "priorities.json")

      expect(Jira.priorities.first[:name]).to eq(fixture_json("priorities").first["name"])
    end
  end

  describe ".statuses" do
    it "returns all statuses" do
      stub_get("/status", "statuses.json")

      expected = fixture_json("statuses").map { |s| s.dig("statusCategory", "key") }
      expect(Jira.statuses.map { |s| s.dig(:statusCategory, :key) }).to eq(expected)
    end
  end

  describe ".resolutions" do
    it "returns all resolutions" do
      stub_get("/resolution", "resolutions.json")

      expect(Jira.resolutions.last[:name]).to eq(fixture_json("resolutions").last["name"])
    end
  end

  describe ".labels" do
    it "returns labels as a paginated response", :aggregate_failures do
      stub_get("/label?maxResults=1000", "labels.json")

      result = Jira.labels(maxResults: 1000)

      expect(a_get("/label?maxResults=1000")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(fixture_json("labels")["total"])
    end
  end
end
