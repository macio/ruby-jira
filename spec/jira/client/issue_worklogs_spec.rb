# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".issue_worklogs" do
    it "returns worklogs for an issue", :aggregate_failures do
      stub_get("/issue/ED-1/worklog", "issue_worklogs")

      result = Jira.issue_worklogs("ED-1")

      expect(a_get("/issue/ED-1/worklog")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(1)
      expect(result.first[:id]).to eq("100028")
    end

    it "passes query options" do
      stub_get("/issue/ED-1/worklog?startAt=0", "issue_worklogs")
      Jira.issue_worklogs("ED-1", startAt: 0)
      expect(a_get("/issue/ED-1/worklog?startAt=0")).to have_been_made
    end
  end

  describe ".add_worklog" do
    it "adds a worklog to an issue", :aggregate_failures do
      payload = { timeSpentSeconds: 3600 }
      stub_post("/issue/ED-1/worklog", "issue_worklog")

      worklog = Jira.add_worklog("ED-1", payload)

      expect(a_post("/issue/ED-1/worklog").with(body: payload.to_json)).to have_been_made
      expect(worklog[:id]).to eq("100028")
    end
  end

  describe ".bulk_delete_worklogs" do
    it "bulk deletes worklogs from an issue", :aggregate_failures do
      payload = { ids: [100_028] }
      stub_delete("/issue/ED-1/worklog", "empty")

      Jira.bulk_delete_worklogs("ED-1", payload)

      expect(a_delete("/issue/ED-1/worklog").with(body: payload.to_json)).to have_been_made
    end
  end

  describe ".bulk_move_worklogs" do
    it "bulk moves worklogs from an issue", :aggregate_failures do
      payload = { ids: [100_028], destinationIssueIdOrKey: "ED-2" }
      stub_post("/issue/ED-1/worklog/move", "empty")

      Jira.bulk_move_worklogs("ED-1", payload)

      expect(a_post("/issue/ED-1/worklog/move").with(body: payload.to_json)).to have_been_made
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
      payload = { timeSpentSeconds: 7200 }
      stub_put("/issue/ED-1/worklog/100028", "issue_worklog")

      worklog = Jira.update_worklog("ED-1", 100_028, payload)

      expect(a_put("/issue/ED-1/worklog/100028").with(body: payload.to_json)).to have_been_made
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

  describe ".deleted_worklog_ids" do
    it "returns IDs of worklogs deleted since a given time", :aggregate_failures do
      stub_get("/worklog/deleted", "deleted_worklog_ids")

      result = Jira.deleted_worklog_ids

      expect(a_get("/worklog/deleted")).to have_been_made
      expect(result).to be_a(Jira::CursorPaginatedResponse)
      expect(result.first[:worklogId]).to eq(103)
    end

    it "passes query options" do
      stub_get("/worklog/deleted?since=1438013671562", "deleted_worklog_ids")
      Jira.deleted_worklog_ids(since: 1_438_013_671_562)
      expect(a_get("/worklog/deleted?since=1438013671562")).to have_been_made
    end
  end

  describe ".worklogs_for_ids" do
    it "returns worklogs for a list of IDs", :aggregate_failures do
      payload = { ids: [100_028] }
      stub_post("/worklog/list", "worklogs")

      result = Jira.worklogs_for_ids(payload)

      expect(a_post("/worklog/list").with(body: payload.to_json)).to have_been_made
      expect(result).to be_an(Array)
      expect(result.first[:id]).to eq("100028")
    end
  end

  describe ".updated_worklog_ids" do
    it "returns IDs of worklogs updated since a given time", :aggregate_failures do
      stub_get("/worklog/updated", "updated_worklog_ids")

      result = Jira.updated_worklog_ids

      expect(a_get("/worklog/updated")).to have_been_made
      expect(result).to be_a(Jira::CursorPaginatedResponse)
      expect(result.first[:worklogId]).to eq(103)
    end

    it "passes query options" do
      stub_get("/worklog/updated?since=1438013671562", "updated_worklog_ids")
      Jira.updated_worklog_ids(since: 1_438_013_671_562)
      expect(a_get("/worklog/updated?since=1438013671562")).to have_been_made
    end
  end
end
