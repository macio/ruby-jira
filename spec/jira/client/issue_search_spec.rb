# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".issue_picker" do
    it "returns issue suggestions", :aggregate_failures do
      stub_get("/issue/picker", "issue_picker")

      result = Jira.issue_picker

      expect(a_get("/issue/picker")).to have_been_made
      expect(result[:sections]).to be_an(Array)
      expect(result[:sections].first[:id]).to eq("hs")
      expect(result[:sections].first[:issues].first[:key]).to eq("EX-1")
    end

    it "passes query options" do
      stub_get("/issue/picker?query=EX", "issue_picker")
      Jira.issue_picker(query: "EX")

      expect(a_get("/issue/picker?query=EX")).to have_been_made
    end
  end

  describe ".match_issues" do
    it "returns JQL match results", :aggregate_failures do
      stub_post("/jql/match", "jql_matches")

      result = Jira.match_issues(issueIds: [10_000, 10_004], jqls: ["project = EX"])

      expect(a_post("/jql/match")).to have_been_made
      expect(result[:matches]).to be_an(Array)
      expect(result[:matches].first[:matchedIssues]).to include(10_000)
    end
  end

  describe ".search_issues" do
    it "returns issues as a PaginatedResponse", :aggregate_failures do
      stub_get("/search", "search_issues")

      result = Jira.search_issues

      expect(a_get("/search")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(1)
      expect(result.first[:id]).to eq("10002")
    end

    it "passes query options" do
      stub_get("/search?maxResults=10", "search_issues")
      Jira.search_issues(maxResults: 10)

      expect(a_get("/search?maxResults=10")).to have_been_made
    end

    it "supports auto_paginate" do
      stub_get("/search", "search_issues")

      all = Jira.search_issues.auto_paginate

      expect(all).to be_an(Array)
      expect(all.first[:key]).to eq("ED-1")
    end
  end

  describe ".search_issues_post" do
    it "returns issues as a PaginatedResponse", :aggregate_failures do
      stub_post("/search", "search_issues")

      result = Jira.search_issues_post(jql: "project = EX", maxResults: 50)

      expect(a_post("/search")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(1)
      expect(result.first[:id]).to eq("10002")
    end
  end

  describe ".approximate_issue_count" do
    it "returns an approximate count of matching issues", :aggregate_failures do
      stub_post("/search/approximate-count", "approximate_issue_count")

      result = Jira.approximate_issue_count(jql: "project = EX")

      expect(a_post("/search/approximate-count")).to have_been_made
      expect(result[:count]).to eq(153)
    end
  end

  describe ".search_issues_jql" do
    it "returns issues as a CursorPaginatedResponse", :aggregate_failures do
      stub_get("/search/jql", "search_issues_jql")

      result = Jira.search_issues_jql

      expect(a_get("/search/jql")).to have_been_made
      expect(result).to be_a(Jira::CursorPaginatedResponse)
      expect(result.next_page?).to be(false)
      expect(result.first[:id]).to eq("10002")
    end

    it "passes query options" do
      stub_get("/search/jql?maxResults=10", "search_issues_jql")
      Jira.search_issues_jql(maxResults: 10)

      expect(a_get("/search/jql?maxResults=10")).to have_been_made
    end

    it "supports auto_paginate across pages", :aggregate_failures do
      stub_get("/search/jql", "search_issues_jql_page1")
      stub_get("/search/jql?nextPageToken=token-123", "search_issues_jql")

      all = Jira.search_issues_jql.auto_paginate

      expect(all.length).to eq(2)
    end
  end

  describe ".search_issues_jql_post" do
    it "returns issues as a CursorPaginatedResponse", :aggregate_failures do
      stub_post("/search/jql", "search_issues_jql")

      result = Jira.search_issues_jql_post(jql: "project = EX")

      expect(a_post("/search/jql")).to have_been_made
      expect(result).to be_a(Jira::CursorPaginatedResponse)
      expect(result.next_page?).to be(false)
      expect(result.first[:id]).to eq("10002")
    end
  end
end
