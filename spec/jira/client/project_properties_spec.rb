# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".project_property_keys" do
    it "returns all property keys for a project", :aggregate_failures do
      stub_get("/project/EX/properties", "project_property_keys")

      result = Jira.project_property_keys("EX")

      expect(a_get("/project/EX/properties")).to have_been_made
      expect(result[:keys]).to be_an(Array)
      expect(result[:keys].first[:key]).to eq("issue.support")
    end
  end

  describe ".project_property" do
    it "returns the value of a project property", :aggregate_failures do
      stub_get("/project/EX/properties/issue.support", "project_property")

      result = Jira.project_property("EX", "issue.support")

      expect(a_get("/project/EX/properties/issue.support")).to have_been_made
      expect(result[:key]).to eq("issue.support")
      expect(result[:value][:"system.support.time"]).to eq("1m")
    end
  end

  describe ".set_project_property" do
    it "sets a project property value", :aggregate_failures do
      payload = { "system.conversation.id" => "abc-123" }
      stub_put("/project/EX/properties/issue.support", "empty")

      Jira.set_project_property("EX", "issue.support", payload)

      expect(a_put("/project/EX/properties/issue.support").with(body: payload.to_json)).to have_been_made
    end
  end

  describe ".delete_project_property" do
    it "deletes a project property", :aggregate_failures do
      stub_delete("/project/EX/properties/issue.support", "empty")

      Jira.delete_project_property("EX", "issue.support")

      expect(a_delete("/project/EX/properties/issue.support")).to have_been_made
    end
  end
end
