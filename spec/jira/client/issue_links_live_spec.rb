# frozen_string_literal: true

require "live_helper"

RSpec.describe Jira::Client do
  let(:scope) { Jira::Live::RunScope.new(project: Jira::Live::PROJECT_KEY) }

  after { scope.cleanup! }

  describe ".issue_link_types" do
    it "returns link types under the issueLinkTypes key, including Blocks" do
      result = record_fixture("issue_link_types") { Jira.issue_link_types }

      expect(result[:issueLinkTypes].map { |type| type[:name] }).to include("Blocks")
    end
  end

  describe "issue link lifecycle" do
    it "creates, reads and deletes a link between two issues", :aggregate_failures do
      outward = scope.create_issue("link outward")
      inward = scope.create_issue("link inward")

      Jira.create_issue_link(type: { name: "Blocks" }, inwardIssue: { key: inward }, outwardIssue: { key: outward })
      link_id = Jira.issue(outward, fields: "issuelinks").fields.issuelinks.first[:id]
      link = record_fixture("issue_link") { Jira.issue_link(link_id) }

      expect(link[:type][:name]).to eq("Blocks")
      expect(link[:outwardIssue][:key]).to eq(outward)
      expect(link[:inwardIssue][:key]).to eq(inward)

      Jira.delete_issue_link(link_id)
      expect { Jira.issue_link(link_id) }.to raise_error(Jira::Error::NotFound)
    end
  end
end
