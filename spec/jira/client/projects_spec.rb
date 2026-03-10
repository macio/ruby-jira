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

  describe ".update_project" do
    it "updates a project", :aggregate_failures do
      stub_put("/project/TEST", "project")

      project = Jira.update_project("TEST", name: "New Name")

      expect(a_put("/project/TEST")).to have_been_made
      expect(project[:key]).to eq("TEST")
      expect(project.dig(:lead, :displayName)).to eq("Test User")
    end
  end

  describe ".delete_project" do
    it "deletes a project" do
      stub_delete("/project/TEST", "empty")

      Jira.delete_project("TEST")

      expect(a_delete("/project/TEST")).to have_been_made
    end
  end

  describe ".project_statuses" do
    it "returns issue types with statuses", :aggregate_failures do
      stub_get("/project/TEST/statuses", "project_statuses")

      statuses = Jira.project_statuses("TEST")

      expect(a_get("/project/TEST/statuses")).to have_been_made
      expect(statuses).to be_an(Array)
      expect(statuses.first[:name]).to eq("Task")
      expect(statuses.first[:id]).to eq("3")
      expect(statuses.first[:statuses].first[:name]).to eq("In Progress")
    end
  end

  describe ".project_issue_type_hierarchy" do
    it "returns the issue type hierarchy", :aggregate_failures do
      stub_get("/project/10030/hierarchy", "project_issue_type_hierarchy")

      hierarchy = Jira.project_issue_type_hierarchy(10_030)

      expect(a_get("/project/10030/hierarchy")).to have_been_made
      expect(hierarchy[:projectId]).to eq(10_030)
      expect(hierarchy[:hierarchy]).to be_an(Array)
      expect(hierarchy[:hierarchy].first[:name]).to eq("Epic")
      expect(hierarchy[:hierarchy].first[:level]).to eq(1)
    end
  end

  describe ".project_notification_scheme" do
    it "returns the notification scheme", :aggregate_failures do
      stub_get("/project/TEST/notificationscheme", "project_notification_scheme")

      scheme = Jira.project_notification_scheme("TEST")

      expect(a_get("/project/TEST/notificationscheme")).to have_been_made
      expect(scheme[:id]).to eq(10_100)
      expect(scheme[:name]).to eq("notification scheme name")
      expect(scheme[:notificationSchemeEvents]).to be_an(Array)
      expect(scheme[:notificationSchemeEvents].first.dig(:event, :name)).to eq("Issue created")
    end

    it "passes query options" do
      stub_get("/project/TEST/notificationscheme?expand=all", "project_notification_scheme")

      Jira.project_notification_scheme("TEST", expand: "all")

      expect(a_get("/project/TEST/notificationscheme?expand=all")).to have_been_made
    end
  end
end
