# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".create_sprint" do
    it "posts sprint payload and returns created sprint", :aggregate_failures do
      payload = { name: "sprint 1", originBoardId: 5, goal: "sprint 1 goal" }

      stub_agile_post("/sprint", "sprint", status_code: 201)
      sprint = Jira.create_sprint(payload)

      expect(a_agile_post("/sprint").with(body: payload.to_json)).to have_been_made
      expect(sprint[:id]).to eq(37)
      expect(sprint[:name]).to eq("sprint 1")
    end
  end

  describe ".sprint" do
    it "gets a sprint by ID", :aggregate_failures do
      stub_agile_get("/sprint/37", "sprint")
      sprint = Jira.sprint(37)

      expect(a_agile_get("/sprint/37")).to have_been_made
      expect(sprint[:id]).to eq(37)
      expect(sprint[:name]).to eq("sprint 1")
      expect(sprint[:state]).to eq("closed")
    end
  end

  describe ".update_sprint" do
    it "partially updates a sprint and returns updated sprint", :aggregate_failures do
      payload = { name: "sprint 1 updated" }

      stub_agile_post("/sprint/37", "sprint")
      sprint = Jira.update_sprint(37, payload)

      expect(a_agile_post("/sprint/37").with(body: payload.to_json)).to have_been_made
      expect(sprint[:id]).to eq(37)
      expect(sprint[:goal]).to eq("sprint 1 goal")
    end
  end

  describe ".replace_sprint" do
    it "fully updates a sprint and returns updated sprint", :aggregate_failures do
      payload = { name: "sprint 1", originBoardId: 5, state: "active" }

      stub_agile_put("/sprint/37", "sprint")
      sprint = Jira.replace_sprint(37, payload)

      expect(a_agile_put("/sprint/37").with(body: payload.to_json)).to have_been_made
      expect(sprint[:id]).to eq(37)
      expect(sprint[:originBoardId]).to eq(5)
    end
  end

  describe ".delete_sprint" do
    it "deletes a sprint" do
      stub_agile_delete("/sprint/37", "empty", status_code: 204)

      Jira.delete_sprint(37)

      expect(a_agile_delete("/sprint/37")).to have_been_made
    end
  end

  describe ".sprint_issues" do
    it "returns paginated issues for a sprint", :aggregate_failures do
      stub_agile_get("/sprint/37/issue", "sprint_issues")
      issues = Jira.sprint_issues(37)

      expect(a_agile_get("/sprint/37/issue")).to have_been_made
      expect(issues).to be_a(Jira::PaginatedResponse)
      expect(issues.total).to eq(1)
      expect(issues.first[:key]).to eq("HSP-1")
    end

    it "passes query options" do
      stub_agile_get("/sprint/37/issue?maxResults=10", "sprint_issues")
      Jira.sprint_issues(37, maxResults: 10)

      expect(a_agile_get("/sprint/37/issue?maxResults=10")).to have_been_made
    end
  end

  describe ".move_issues_to_sprint" do
    it "moves issues to a sprint" do
      stub_agile_post("/sprint/37/issue", "empty", status_code: 204)

      Jira.move_issues_to_sprint(37, issues: %w[TEST-1 TEST-2])

      expect(
        a_agile_post("/sprint/37/issue").with(body: { issues: %w[TEST-1 TEST-2] }.to_json)
      ).to have_been_made
    end
  end

  describe ".sprint_property_keys" do
    it "returns property keys for a sprint", :aggregate_failures do
      stub_agile_get("/sprint/37/properties", "sprint_properties")
      result = Jira.sprint_property_keys(37)

      expect(a_agile_get("/sprint/37/properties")).to have_been_made
      expect(result[:keys]).to be_an(Array)
      expect(result[:keys].first[:key]).to eq("issue.support")
    end
  end

  describe ".sprint_property" do
    it "returns a single sprint property", :aggregate_failures do
      stub_agile_get("/sprint/37/properties/issue.support", "sprint_property")
      result = Jira.sprint_property(37, "issue.support")

      expect(a_agile_get("/sprint/37/properties/issue.support")).to have_been_made
      expect(result[:key]).to eq("issue.support")
      expect(result[:value]).not_to be_nil
    end
  end

  describe ".set_sprint_property" do
    it "sets a sprint property" do
      value = { "system.support.time" => "1m" }

      stub_agile_put("/sprint/37/properties/issue.support", "empty")
      Jira.set_sprint_property(37, "issue.support", value)

      expect(
        a_agile_put("/sprint/37/properties/issue.support").with(body: value.to_json)
      ).to have_been_made
    end
  end

  describe ".delete_sprint_property" do
    it "deletes a sprint property" do
      stub_agile_delete("/sprint/37/properties/issue.support", "empty", status_code: 204)

      Jira.delete_sprint_property(37, "issue.support")

      expect(a_agile_delete("/sprint/37/properties/issue.support")).to have_been_made
    end
  end

  describe ".swap_sprint" do
    it "swaps a sprint with another sprint" do
      stub_agile_post("/sprint/37/swap", "empty", status_code: 204)

      Jira.swap_sprint(37, sprint_to_swap_with: 42)

      expect(
        a_agile_post("/sprint/37/swap").with(body: { sprintToSwapWith: 42 }.to_json)
      ).to have_been_made
    end
  end
end
