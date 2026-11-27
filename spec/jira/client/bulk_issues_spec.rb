# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".bulk_delete_issues" do
    it "submits the issue keys and returns the task ID", :aggregate_failures do
      payload = fixture_json("bulk_delete_issues_request")
      stub_post("/bulk/issues/delete", "bulk_delete_issues.json", status_code: 201)

      result = Jira.bulk_delete_issues(payload["selectedIssueIdsOrKeys"])

      expect(a_post("/bulk/issues/delete").with(body: payload)).to have_been_made
      expect(result[:taskId]).to eq(fixture_json("bulk_delete_issues")["taskId"])
    end
  end
end
