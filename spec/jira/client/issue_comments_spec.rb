# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".comments_by_ids" do
    it "returns comments for given IDs", :aggregate_failures do
      stub_post("/comment/list", "comments_by_ids")

      result = Jira.comments_by_ids(ids: [10_000])

      expect(a_post("/comment/list")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(1)
      expect(result.first[:id]).to eq("10000")
      expect(result.first.dig(:author, :displayName)).to eq("Mia Krystof")
    end

    it "passes query options" do
      stub_post("/comment/list?expand=renderedBody", "comments_by_ids")

      Jira.comments_by_ids({ ids: [10_000] }, expand: "renderedBody")

      expect(a_post("/comment/list?expand=renderedBody")).to have_been_made
    end
  end

  describe ".issue_comments" do
    it "returns comments as a PaginatedResponse", :aggregate_failures do
      stub_get("/issue/ED-1/comment", "issue_comments")

      result = Jira.issue_comments("ED-1")

      expect(a_get("/issue/ED-1/comment")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(1)
      expect(result.first[:id]).to eq("10000")
    end

    it "passes query options" do
      stub_get("/issue/ED-1/comment?orderBy=created", "issue_comments")
      Jira.issue_comments("ED-1", orderBy: "created")

      expect(a_get("/issue/ED-1/comment?orderBy=created")).to have_been_made
    end

    it "supports auto_paginate" do
      stub_get("/issue/ED-1/comment", "issue_comments")

      all = Jira.issue_comments("ED-1").auto_paginate

      expect(all).to be_an(Array)
      expect(all.first[:id]).to eq("10000")
    end
  end

  describe ".add_comment" do
    it "adds a comment to an issue", :aggregate_failures do
      payload = { body: { type: "doc", version: 1, content: [] } }
      stub_post("/issue/ED-1/comment", "issue_comment")

      comment = Jira.add_comment("ED-1", payload)

      expect(a_post("/issue/ED-1/comment").with(body: payload.to_json)).to have_been_made
      expect(comment[:id]).to eq("10000")
    end

    it "passes query options" do
      stub_post("/issue/ED-1/comment?expand=renderedBody", "issue_comment")
      Jira.add_comment("ED-1", {}, expand: "renderedBody")
      expect(a_post("/issue/ED-1/comment?expand=renderedBody")).to have_been_made
    end
  end

  describe ".issue_comment" do
    it "returns a single comment", :aggregate_failures do
      stub_get("/issue/ED-1/comment/10000", "issue_comment")

      comment = Jira.issue_comment("ED-1", 10_000)

      expect(a_get("/issue/ED-1/comment/10000")).to have_been_made
      expect(comment[:id]).to eq("10000")
      expect(comment.dig(:author, :displayName)).to eq("Mia Krystof")
    end
  end

  describe ".update_comment" do
    it "updates a comment on an issue", :aggregate_failures do
      payload = { body: { type: "doc", version: 1, content: [] } }
      stub_put("/issue/ED-1/comment/10000", "issue_comment")

      comment = Jira.update_comment("ED-1", 10_000, payload)

      expect(a_put("/issue/ED-1/comment/10000").with(body: payload.to_json)).to have_been_made
      expect(comment[:id]).to eq("10000")
    end

    it "passes query options" do
      stub_put("/issue/ED-1/comment/10000?expand=renderedBody", "issue_comment")
      Jira.update_comment("ED-1", 10_000, {}, expand: "renderedBody")
      expect(a_put("/issue/ED-1/comment/10000?expand=renderedBody")).to have_been_made
    end
  end

  describe ".delete_comment" do
    it "deletes a comment from an issue" do
      stub_delete("/issue/ED-1/comment/10000", "empty")

      Jira.delete_comment("ED-1", 10_000)

      expect(a_delete("/issue/ED-1/comment/10000")).to have_been_made
    end
  end
end
