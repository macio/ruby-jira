# frozen_string_literal: true

require "live_helper"

RSpec.describe Jira::Client do
  let(:scope) { Jira::Live::RunScope.new(project: Jira::Live::PROJECT_KEY) }

  after { scope.cleanup! }

  describe ".issue_changelogs_by_ids" do
    it "returns the requested changelog entries of a freshly edited issue", :aggregate_failures do
      key = scope.create_issue("changelog")
      Jira.edit_issue(key, { fields: { summary: "#{scope.prefix} changelog edited" } })
      ids = Jira.issue_changelog(key).map { |history| history[:id].to_i }

      result = record_fixture("issue_changelogs_by_ids") { Jira.issue_changelogs_by_ids(key, ids) }

      expect(ids).not_to be_empty
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.map { |history| history[:id].to_i }).to match_array(ids)
      expect(result.flat_map { |history| history[:items].map { |item| item[:field] } }).to include("summary")

      scope.cleanup!
      expect { Jira.issue(key) }.to raise_error(Jira::Error::NotFound)
    end
  end
end
