# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".create_issue" do
    it "posts issue payload and returns created issue" do
      payload = {
        fields: {
          summary: "New issue",
          project: { key: "TEST" }
        }
      }

      stub_post("/issue", "issue")
      issue = Jira.create_issue(payload)

      expect(a_post("/issue").with(body: payload.to_json)).to have_been_made
      expect(issue[:key]).to eq("TEST-11")
      expect(issue[:id]).to eq("100011")
    end
  end

  describe ".issue" do
    it "gets a single issue by key" do
      stub_get("/issue/TEST-11", "issue")
      issue = Jira.issue("TEST-11")

      expect(a_get("/issue/TEST-11")).to have_been_made
      expect(issue[:key]).to eq("TEST-11")
      expect(issue[:id]).to eq("100011")
    end

    it "passes query options" do
      stub_get("/issue/TEST-11?expand=names", "issue")
      Jira.issue("TEST-11", expand: "names")

      expect(a_get("/issue/TEST-11?expand=names")).to have_been_made
    end
  end

  describe ".edit_issue" do
    it "updates issue and returns updated issue" do
      payload = { fields: { summary: "Updated issue" } }

      stub_put("/issue/TEST-11?notifyUsers=false", "issue")
      issue = Jira.edit_issue("TEST-11", payload, notifyUsers: false)

      expect(a_put("/issue/TEST-11?notifyUsers=false").with(body: payload.to_json)).to have_been_made
      expect(issue[:key]).to eq("TEST-11")
    end
  end
end
