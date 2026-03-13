# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".project_categories" do
    it "returns all project categories", :aggregate_failures do
      stub_get("/projectCategory", "project_categories")

      result = Jira.project_categories

      expect(a_get("/projectCategory")).to have_been_made
      expect(result).to be_an(Array)
      expect(result.first[:id]).to eq("10000")
      expect(result.first[:name]).to eq("FIRST")
    end
  end

  describe ".create_project_category" do
    it "creates a project category", :aggregate_failures do
      payload = { name: "NEW", description: "New category" }
      stub_post("/projectCategory", "project_category")

      result = Jira.create_project_category(payload)

      expect(a_post("/projectCategory").with(body: payload.to_json)).to have_been_made
      expect(result[:id]).to eq("10000")
      expect(result[:name]).to eq("FIRST")
    end
  end

  describe ".project_category" do
    it "returns a project category by ID", :aggregate_failures do
      stub_get("/projectCategory/10000", "project_category")

      result = Jira.project_category("10000")

      expect(a_get("/projectCategory/10000")).to have_been_made
      expect(result[:id]).to eq("10000")
      expect(result[:name]).to eq("FIRST")
      expect(result[:description]).to eq("First Project Category")
    end
  end

  describe ".update_project_category" do
    it "updates a project category", :aggregate_failures do
      payload = { name: "UPDATED", description: "Updated category" }
      stub_put("/projectCategory/10000", "project_category")

      result = Jira.update_project_category("10000", payload)

      expect(a_put("/projectCategory/10000").with(body: payload.to_json)).to have_been_made
      expect(result[:id]).to eq("10000")
    end
  end

  describe ".delete_project_category" do
    it "deletes a project category", :aggregate_failures do
      stub_delete("/projectCategory/10000", "empty")

      Jira.delete_project_category("10000")

      expect(a_delete("/projectCategory/10000")).to have_been_made
    end
  end
end
