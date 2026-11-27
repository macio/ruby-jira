# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".bulk_delete_issues" do
    it "submits the issue keys and returns the task ID", :aggregate_failures do
      payload = { selectedIssueIdsOrKeys: %w[ED-1 ED-2], sendBulkNotification: false }
      stub_request(:post, "#{Jira.endpoint}/rest/api/3/bulk/issues/delete")
        .with(body: payload.to_json)
        .to_return(body: load_fixture("bulk_delete_issues.json"), status: 201)

      result = Jira.bulk_delete_issues(%w[ED-1 ED-2])

      expect(
        a_request(:post, "#{Jira.endpoint}/rest/api/3/bulk/issues/delete")
                .with(body: payload.to_json)
      ).to have_been_made
      expect(result[:taskId]).to eq("10000")
    end
  end
end
