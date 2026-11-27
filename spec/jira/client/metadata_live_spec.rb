# frozen_string_literal: true

require "live_helper"

RSpec.describe Jira::Client do
  let(:task_type_id) { Jira.issue_types.find { |type| type[:name] == "Task" }[:id] }

  describe ".create_metadata" do
    it "returns the project's issue types with their create fields", :aggregate_failures do
      result = record_fixture("create_metadata") { Jira.create_metadata(Jira::Live::PROJECT_KEY) }

      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.map { |type| type[:name] }).to include("Task")
    end
  end

  describe ".create_metadata_for_issue_type" do
    it "lists the create fields of the Task type, including summary", :aggregate_failures do
      result = record_fixture("create_metadata_for_issue_type") do
        Jira.create_metadata_for_issue_type(Jira::Live::PROJECT_KEY, task_type_id)
      end

      expect(result).to be_a(Jira::PaginatedResponse)
      summary = result.find { |field| field[:fieldId] == "summary" }
      expect(summary[:required]).to be(true)
    end
  end
end
