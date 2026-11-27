# frozen_string_literal: true

require "spec_helper"
require_relative "run_scope"

RSpec.describe Jira::Live::RunScope do
  subject(:scope) { described_class.new(client: client, clock: clock) }

  let(:client) { instance_double(Jira::Client) }
  let(:clock) { class_double(Time, now: Time.at(1_700_000_000)) }

  it "builds the prefix from the run start time" do
    expect(scope.prefix).to eq("ruby-jira-live-1700000000")
  end

  describe "#create_issue" do
    it "creates a labelled issue with the run prefix and tracks it for cleanup", :aggregate_failures do
      allow(client).to receive_messages(create_issue: { key: "TEST-5" }, delete_issue: nil)

      key = scope.create_issue("changelog")
      scope.cleanup!

      expect(key).to eq("TEST-5")
      expect(client).to have_received(:create_issue).with(
        fields: {
          project:   { key: "TEST" },
          issuetype: { name: "Task" },
          summary:   "ruby-jira-live-1700000000 changelog",
          labels:    ["ruby-jira-live"]
        }
      )
      expect(client).to have_received(:delete_issue).with("TEST-5")
    end
  end

  describe "#cleanup!" do
    it "deletes every tracked issue even when one deletion fails", :aggregate_failures do
      allow(client).to receive(:delete_issue)
      allow(client).to receive(:delete_issue).with("TEST-2").and_raise(Jira::Error::Parsing, "boom")
      %w[TEST-1 TEST-2 TEST-3].each { |key| scope.track_issue(key) }

      expect { scope.cleanup! }.to raise_error(described_class::CleanupError, /TEST-2: Jira::Error::Parsing: boom/)
      expect(client).to have_received(:delete_issue).with("TEST-1")
      expect(client).to have_received(:delete_issue).with("TEST-3")
    end

    it "treats an already deleted issue as cleaned up" do
      allow(client).to receive(:delete_issue).and_raise(Jira::Error::NotFound.allocate)
      scope.track_issue("TEST-1")

      expect { scope.cleanup! }.not_to raise_error
    end

    it "does nothing on a second call" do
      allow(client).to receive(:delete_issue)
      scope.track_issue("TEST-1")
      scope.cleanup!
      scope.cleanup!

      expect(client).to have_received(:delete_issue).once
    end
  end

  describe ".sweep_stale!" do
    let(:page) { instance_double(Jira::CursorPaginatedResponse, auto_paginate: [{ key: "TEST-9" }]) }
    let(:versions) do
      [{ id: "1", name: "ruby-jira-live-1699990000 old" }, { id: "2", name: "ruby-jira-live-1699999990 fresh" },
       { id: "3", name: "1.0" }]
    end
    let(:components) { [{ id: "7", name: "ruby-jira-live-1699990000 old" }] }

    before do
      allow(client).to receive_messages(
        search_issues_jql:  page,
        delete_issue:       nil,
        project_versions:   versions,
        delete_version:     nil,
        project_components: components,
        delete_component:   nil
      )
      described_class.sweep_stale!(client: client, clock: clock)
    end

    it "deletes labelled issues older than one hour", :aggregate_failures do
      expect(client).to have_received(:search_issues_jql)
        .with(jql: a_string_including('labels = "ruby-jira-live"', "created <= -1h"), fields: "key")
      expect(client).to have_received(:delete_issue).with("TEST-9")
    end

    it "deletes only prefixed versions and components older than one hour", :aggregate_failures do
      expect(client).to have_received(:delete_version).with("1").once
      expect(client).not_to have_received(:delete_version).with("2")
      expect(client).not_to have_received(:delete_version).with("3")
      expect(client).to have_received(:delete_component).with("7")
    end
  end

  describe "#on_cleanup" do
    it "runs registered cleanups before deleting issues, collecting failures", :aggregate_failures do
      calls = []
      allow(client).to receive(:delete_issue) { |key| calls << key }
      scope.track_issue("TEST-1")
      scope.on_cleanup("version 1") { calls << "version 1" }
      scope.on_cleanup("component 2") { raise Jira::Error::Parsing, "boom" }

      expect { scope.cleanup! }.to raise_error(described_class::CleanupError, /component 2: Jira::Error::Parsing: boom/)
      expect(calls).to eq(["version 1", "TEST-1"])
    end
  end
end
