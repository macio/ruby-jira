# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Webhook::Event do
  describe ".parse" do
    it "parses an issue created delivery", :aggregate_failures do
      event = described_class.parse(load_fixture("webhook_issue_created.json").read)

      expect(event).to be_a(described_class)
      expect(event).to be_created
      expect(event.issue[:key]).to eq("ED-1")
      expect(event.user[:displayName]).to eq("Mia Krystof")
    end

    it "parses an issue updated delivery and exposes the changelog", :aggregate_failures do
      event = described_class.parse(load_fixture("webhook_issue_updated.json").read)

      expect(event).to be_updated
      expect(event.changelog[:items].first[:toString]).to eq("In Progress")
    end

    it "accepts an already decoded hash" do
      body = JSON.parse(load_fixture("webhook_issue_created.json").read)

      expect(described_class.parse(body)).to be_created
    end

    it "returns other events as a raw hash" do
      body = { webhookEvent: "jira:version_released", version: { name: "1.0" } }.to_json

      expect(described_class.parse(body)).to eq(webhookEvent: "jira:version_released", version: { name: "1.0" })
    end
  end
end
