# frozen_string_literal: true

require "live_helper"

RSpec.describe Jira::Client do
  describe ".fields" do
    it "returns system and custom fields", :aggregate_failures do
      result = record_fixture("fields") { Jira.fields }

      expect(result).to be_an(Array)
      expect(result.map { |field| field[:id] }).to include("summary")
      expect(result.any? { |field| field[:custom] }).to be(true)
    end
  end

  describe ".field_search" do
    it "returns custom fields as a paginated response", :aggregate_failures do
      result = record_fixture("field_search") { Jira.field_search(type: "custom") }

      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.first[:id]).to start_with("customfield_")
    end
  end

  describe ".issue_types" do
    it "includes the Task type used by live specs" do
      result = record_fixture("issue_types") { Jira.issue_types }

      expect(result.map { |type| type[:name] }).to include("Task")
    end
  end

  describe ".priorities" do
    it "returns priorities with names" do
      result = record_fixture("priorities") { Jira.priorities }

      expect(result.first[:name]).to be_a(String)
    end
  end

  describe ".statuses" do
    it "returns statuses with a status category" do
      result = record_fixture("statuses") { Jira.statuses }

      expect(result.first.dig(:statusCategory, :key)).to be_a(String)
    end
  end

  describe ".resolutions" do
    it "returns resolutions with names" do
      result = record_fixture("resolutions") { Jira.resolutions }

      expect(result.first[:name]).to be_a(String)
    end
  end

  describe ".labels" do
    it "returns labels as a paginated response of strings", :aggregate_failures do
      result = record_fixture("labels") { Jira.labels(maxResults: 1000) }

      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.to_a).to all(be_a(String))
    end
  end
end
