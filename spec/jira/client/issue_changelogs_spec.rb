# frozen_string_literal: true

require "spec_helper"

# Fixtures are recorded by issue_changelogs_live_spec.rb (rake live):
#   issue_changelogs_by_ids.json         - response returned by Jira
#   issue_changelogs_by_ids_request.json - request body Jira accepted
RSpec.describe Jira::Client do
  describe ".issue_changelogs_by_ids" do
    it "sends the payload Jira accepted and returns the histories", :aggregate_failures do
      accepted_payload = fixture_json("issue_changelogs_by_ids_request")
      expected_ids = fixture_json("issue_changelogs_by_ids")["histories"].map { |history| history["id"] }
      stub_post("/issue/ED-1/changelog/list", "issue_changelogs_by_ids")

      result = Jira.issue_changelogs_by_ids("ED-1", accepted_payload["changelogIds"])

      expect(a_post("/issue/ED-1/changelog/list").with(body: accepted_payload)).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.map { |history| history[:id] }).to eq(expected_ids)
    end
  end
end
