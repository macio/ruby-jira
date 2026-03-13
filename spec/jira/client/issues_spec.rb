# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".create_issue" do
    it "posts issue payload and returns created issue", :aggregate_failures do
      payload = {
        fields: {
          summary: "New issue",
          project: { key: "TEST" }
        }
      }

      stub_post("/issue", "issue")
      issue = Jira.create_issue(payload)

      expect(a_post("/issue").with(body: payload.to_json)).to have_been_made
      expect(issue[:key]).to eq("ED-1")
      expect(issue[:id]).to eq("10002")
    end
  end

  describe ".bulk_create_issues" do
    it "creates multiple issues in a single request", :aggregate_failures do
      stub_post("/issue/bulk", "bulk_issues")
      result = Jira.bulk_create_issues({ issueUpdates: [] })

      expect(a_post("/issue/bulk")).to have_been_made
      expect(result[:issues]).to be_an(Array)
      expect(result[:issues].first[:key]).to eq("ED-24")
    end
  end

  describe ".issue" do
    it "gets a single issue by key", :aggregate_failures do
      stub_get("/issue/ED-1", "issue")
      issue = Jira.issue("ED-1")

      expect(a_get("/issue/ED-1")).to have_been_made
      expect(issue[:key]).to eq("ED-1")
      expect(issue[:id]).to eq("10002")
    end

    it "passes query options" do
      stub_get("/issue/ED-1?expand=names", "issue")
      Jira.issue("ED-1", expand: "names")

      expect(a_get("/issue/ED-1?expand=names")).to have_been_made
    end
  end

  describe ".edit_issue" do
    it "updates issue and returns updated issue", :aggregate_failures do
      payload = { fields: { summary: "Updated issue" } }

      stub_put("/issue/ED-1?notifyUsers=false", "issue")
      issue = Jira.edit_issue("ED-1", payload, notifyUsers: false)

      expect(a_put("/issue/ED-1?notifyUsers=false").with(body: payload.to_json)).to have_been_made
      expect(issue[:key]).to eq("ED-1")
    end
  end

  describe ".delete_issue" do
    it "deletes an issue" do
      stub_delete("/issue/ED-1", "empty")

      Jira.delete_issue("ED-1")

      expect(a_delete("/issue/ED-1")).to have_been_made
    end

    it "passes query options" do
      stub_delete("/issue/ED-1?deleteSubtasks=true", "empty")

      Jira.delete_issue("ED-1", deleteSubtasks: true)

      expect(a_delete("/issue/ED-1?deleteSubtasks=true")).to have_been_made
    end
  end

  describe ".assign_issue" do
    it "assigns an issue to a user" do
      stub_put("/issue/ED-1/assignee", "empty")

      Jira.assign_issue("ED-1", accountId: "5b10a2844c20165700ede21g")

      expect(
        a_put("/issue/ED-1/assignee")
          .with(body: { accountId: "5b10a2844c20165700ede21g" }.to_json)
      ).to have_been_made
    end
  end

  describe ".issue_transitions" do
    it "returns transitions for an issue", :aggregate_failures do
      stub_get("/issue/ED-1/transitions", "issue_transitions")

      result = Jira.issue_transitions("ED-1")

      expect(a_get("/issue/ED-1/transitions")).to have_been_made
      expect(result[:transitions]).to be_an(Array)
      expect(result[:transitions].first[:id]).to eq("2")
    end

    it "passes query options" do
      stub_get("/issue/ED-1/transitions?expand=transitions.fields", "issue_transitions")
      Jira.issue_transitions("ED-1", expand: "transitions.fields")

      expect(a_get("/issue/ED-1/transitions?expand=transitions.fields")).to have_been_made
    end
  end

  describe ".transition_issue" do
    it "performs a transition on an issue" do
      stub_post("/issue/ED-1/transitions", "empty")

      Jira.transition_issue("ED-1", transition: { id: "2" })

      expect(
        a_post("/issue/ED-1/transitions")
          .with(body: { transition: { id: "2" } }.to_json)
      ).to have_been_made
    end
  end

  describe ".issue_changelog" do
    it "returns paginated changelog for an issue", :aggregate_failures do
      stub_get("/issue/ED-1/changelog", "issue_changelog")

      result = Jira.issue_changelog("ED-1")

      expect(a_get("/issue/ED-1/changelog")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(5)
      expect(result.next_page?).to be(true)
      expect(result.first[:id]).to eq("10001")
    end
  end

  describe ".issue_watchers" do
    it "returns watchers for an issue", :aggregate_failures do
      stub_get("/issue/ED-1/watchers", "issue_watchers")

      result = Jira.issue_watchers("ED-1")

      expect(a_get("/issue/ED-1/watchers")).to have_been_made
      expect(result[:watchCount]).to eq(1)
      expect(result[:isWatching]).to be(false)
      expect(result[:watchers].first[:displayName]).to eq("Mia Krystof")
    end
  end

  describe ".add_watcher" do
    it "adds a watcher to an issue" do
      stub_post("/issue/ED-1/watchers", "empty")

      Jira.add_watcher("ED-1", "5b10a2844c20165700ede21g")

      expect(
        a_post("/issue/ED-1/watchers")
          .with(body: "5b10a2844c20165700ede21g")
      ).to have_been_made
    end
  end

  describe ".remove_watcher" do
    it "removes a watcher from an issue" do
      stub_delete("/issue/ED-1/watchers?accountId=5b10a2844c20165700ede21g", "empty")

      Jira.remove_watcher("ED-1", account_id: "5b10a2844c20165700ede21g")

      expect(a_delete("/issue/ED-1/watchers?accountId=5b10a2844c20165700ede21g")).to have_been_made
    end
  end

  describe ".issue_votes" do
    it "returns votes for an issue", :aggregate_failures do
      stub_get("/issue/ED-1/votes", "issue_votes")

      result = Jira.issue_votes("ED-1")

      expect(a_get("/issue/ED-1/votes")).to have_been_made
      expect(result[:hasVoted]).to be(true)
      expect(result[:voters]).to be_an(Array)
    end
  end

  describe ".add_vote" do
    it "adds a vote to an issue" do
      stub_post("/issue/ED-1/votes", "empty")

      Jira.add_vote("ED-1")

      expect(a_post("/issue/ED-1/votes")).to have_been_made
    end
  end

  describe ".remove_vote" do
    it "removes a vote from an issue" do
      stub_delete("/issue/ED-1/votes", "empty")

      Jira.remove_vote("ED-1")

      expect(a_delete("/issue/ED-1/votes")).to have_been_made
    end
  end

  describe ".issue_worklogs" do
    it "returns worklogs as a PaginatedResponse", :aggregate_failures do
      stub_get("/issue/ED-1/worklog", "issue_worklogs")

      result = Jira.issue_worklogs("ED-1")

      expect(a_get("/issue/ED-1/worklog")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(1)
      expect(result.first[:id]).to eq("100028")
    end
  end

  describe ".add_worklog" do
    it "adds a worklog to an issue", :aggregate_failures do
      stub_post("/issue/ED-1/worklog", "issue_worklog")

      worklog = Jira.add_worklog("ED-1", timeSpentSeconds: 3600)

      expect(a_post("/issue/ED-1/worklog")).to have_been_made
      expect(worklog[:id]).to eq("100028")
    end
  end

  describe ".worklog" do
    it "returns a single worklog", :aggregate_failures do
      stub_get("/issue/ED-1/worklog/100028", "issue_worklog")

      worklog = Jira.worklog("ED-1", 100_028)

      expect(a_get("/issue/ED-1/worklog/100028")).to have_been_made
      expect(worklog[:id]).to eq("100028")
      expect(worklog.dig(:author, :displayName)).to eq("Mia Krystof")
    end
  end

  describe ".update_worklog" do
    it "updates a worklog on an issue", :aggregate_failures do
      stub_put("/issue/ED-1/worklog/100028", "issue_worklog")

      worklog = Jira.update_worklog("ED-1", 100_028, timeSpentSeconds: 7200)

      expect(a_put("/issue/ED-1/worklog/100028")).to have_been_made
      expect(worklog[:id]).to eq("100028")
    end
  end

  describe ".delete_worklog" do
    it "deletes a worklog from an issue" do
      stub_delete("/issue/ED-1/worklog/100028", "empty")

      Jira.delete_worklog("ED-1", 100_028)

      expect(a_delete("/issue/ED-1/worklog/100028")).to have_been_made
    end
  end

  describe ".issue_remote_links" do
    it "returns remote links for an issue", :aggregate_failures do
      stub_get("/issue/ED-1/remotelink", "issue_remote_links")

      result = Jira.issue_remote_links("ED-1")

      expect(a_get("/issue/ED-1/remotelink")).to have_been_made
      expect(result).to be_an(Array)
      expect(result.first[:id]).to eq(10_000)
      expect(result.first.dig(:application, :name)).to eq("My Acme Tracker")
    end
  end

  describe ".create_or_update_remote_link" do
    it "creates or updates a remote link", :aggregate_failures do
      stub_post("/issue/ED-1/remotelink", "issue_remote_link")

      result = Jira.create_or_update_remote_link("ED-1", object: { url: "http://example.com", title: "Example" })

      expect(a_post("/issue/ED-1/remotelink")).to have_been_made
      expect(result[:id]).to eq(10_000)
    end
  end

  describe ".remote_link" do
    it "returns a single remote link", :aggregate_failures do
      stub_get("/issue/ED-1/remotelink/10000", "issue_remote_link")

      result = Jira.remote_link("ED-1", 10_000)

      expect(a_get("/issue/ED-1/remotelink/10000")).to have_been_made
      expect(result[:id]).to eq(10_000)
      expect(result.dig(:application, :name)).to eq("My Acme Tracker")
    end
  end

  describe ".update_remote_link" do
    it "updates a remote link on an issue" do
      stub_put("/issue/ED-1/remotelink/10000", "empty")

      Jira.update_remote_link("ED-1", 10_000, object: { url: "http://example.com", title: "Updated" })

      expect(a_put("/issue/ED-1/remotelink/10000")).to have_been_made
    end
  end

  describe ".delete_remote_link" do
    it "deletes a remote link from an issue" do
      stub_delete("/issue/ED-1/remotelink/10000", "empty")

      Jira.delete_remote_link("ED-1", 10_000)

      expect(a_delete("/issue/ED-1/remotelink/10000")).to have_been_made
    end
  end
end
