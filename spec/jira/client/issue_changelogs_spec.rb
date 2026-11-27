# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".issue_changelogs_by_ids" do
    it "posts the changelog IDs and returns the histories", :aggregate_failures do
      stub_post("/issue/ED-1/changelog/list", "issue_changelogs_by_ids")

      result = Jira.issue_changelogs_by_ids("ED-1", [10_001, 10_002])

      expect(a_post("/issue/ED-1/changelog/list")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.map { |h| h[:id] }).to eq(%w[10001 10002])
    end
  end
end
