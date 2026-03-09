# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".projects" do
    it "returns paginated project search response", :aggregate_failures do
      stub_get("/project/search?status=live", "projects")

      projects = Jira.projects(status: "live")

      expect(a_get("/project/search?status=live")).to have_been_made
      expect(projects).to be_a(Jira::PaginatedResponse)
      expect(projects.total).to eq(2)
      expect(projects.first[:key]).to eq("TEST")
      expect(projects.last[:key]).to eq("DEMO")
      expect(projects.next_page?).to be(true)
    end
  end

  describe ".project" do
    it "gets a single project" do
      stub_get("/project/TEST", "project")
      project = Jira.project("TEST")

      expect(a_get("/project/TEST")).to have_been_made
      expect(project[:key]).to eq("TEST")
      expect(project.dig(:lead, :displayName)).to eq("Test User")
    end

    it "passes query options" do
      stub_get("/project/TEST?expand=description", "project")
      Jira.project("TEST", expand: "description")

      expect(a_get("/project/TEST?expand=description")).to have_been_made
    end
  end

  describe ".archive_project" do
    it "archives project by key" do
      stub_post("/project/TEST/archive", "empty")

      Jira.archive_project("TEST")

      expect(a_post("/project/TEST/archive")).to have_been_made
    end
  end
end
