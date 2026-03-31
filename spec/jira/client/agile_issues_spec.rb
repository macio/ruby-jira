# frozen_string_literal: true

RSpec.describe Jira::Client::AgileIssues do
  describe ".rank_issues" do
    it "ranks issues before another issue", :aggregate_failures do
      stub_agile_put("/issue/rank", "empty", status_code: 204)

      Jira.rank_issues({ issues: %w[TEST-1 TEST-2], rankBeforeIssue: "TEST-3" })

      expect(a_agile_put("/issue/rank")).to have_been_made
    end
  end

  describe ".agile_issue" do
    it "returns an issue with agile fields", :aggregate_failures do
      stub_agile_get("/issue/HSP-1", "agile_issue")

      result = Jira.agile_issue("HSP-1")

      expect(a_agile_get("/issue/HSP-1")).to have_been_made
      expect(result[:key]).to eq("HSP-1")
      expect(result[:id]).to eq("10001")
      expect(result[:fields][:sprint][:id]).to eq(37)
    end

    it "passes query options" do
      stub_agile_get("/issue/HSP-1?fields=summary%2Cstatus", "agile_issue")
      Jira.agile_issue("HSP-1", fields: "summary,status")
      expect(a_agile_get("/issue/HSP-1?fields=summary%2Cstatus")).to have_been_made
    end
  end

  describe ".issue_estimation" do
    it "returns the estimation for an issue", :aggregate_failures do
      stub_agile_get("/issue/HSP-1/estimation", "issue_estimation")

      result = Jira.issue_estimation("HSP-1")

      expect(a_agile_get("/issue/HSP-1/estimation")).to have_been_made
      expect(result[:fieldId]).to eq("customfield_12532")
      expect(result[:value]).to eq("8.0")
    end

    it "passes boardId as query option" do
      stub_agile_get("/issue/HSP-1/estimation?boardId=84", "issue_estimation")
      Jira.issue_estimation("HSP-1", boardId: 84)
      expect(a_agile_get("/issue/HSP-1/estimation?boardId=84")).to have_been_made
    end
  end

  describe ".update_issue_estimation" do
    it "updates the estimation for an issue", :aggregate_failures do
      stub_agile_put("/issue/HSP-1/estimation", "issue_estimation")

      result = Jira.update_issue_estimation("HSP-1", { value: "13.0" })

      expect(a_agile_put("/issue/HSP-1/estimation")).to have_been_made
      expect(result[:fieldId]).to eq("customfield_12532")
    end

    it "passes boardId as query option" do
      stub_agile_put("/issue/HSP-1/estimation?boardId=84", "issue_estimation")
      Jira.update_issue_estimation("HSP-1", { value: "13.0" }, boardId: 84)
      expect(a_agile_put("/issue/HSP-1/estimation?boardId=84")).to have_been_made
    end
  end
end
