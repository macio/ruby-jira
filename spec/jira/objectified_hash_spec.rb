# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::ObjectifiedHash do
  subject(:obj) { described_class.new(hash) }

  let(:hash) do
    {
      id:         "10000",
      key:        "TEST",
      lead:       {
        accountId:   "abc123",
        displayName: "Test User"
      },
      issueTypes: [
        { id: "1", name: "Task" },
        { id: "2", name: "Bug" }
      ]
    }
  end

  describe "dot-notation access" do
    it "accesses top-level keys as methods" do
      expect(obj.id).to eq("10000")
      expect(obj.key).to eq("TEST")
    end

    it "wraps nested hashes in ObjectifiedHash" do
      expect(obj.lead).to be_a(described_class)
      expect(obj.lead.displayName).to eq("Test User")
    end

    it "wraps hashes inside arrays in ObjectifiedHash" do
      expect(obj.issueTypes).to be_an(Array)
      expect(obj.issueTypes.first).to be_a(described_class)
      expect(obj.issueTypes.first.name).to eq("Task")
    end
  end

  describe "bracket access" do
    it "supports symbol keys" do
      expect(obj[:id]).to eq("10000")
      expect(obj[:lead]).to be_a(described_class)
    end

    it "supports string keys" do
      expect(obj["id"]).to eq("10000")
    end
  end

  describe "#dig" do
    it "traverses nested ObjectifiedHash objects" do
      expect(obj.dig(:lead, :displayName)).to eq("Test User")
    end

    it "returns nil for missing keys" do
      expect(obj.dig(:lead, :missing)).to be_nil
    end
  end

  describe "#to_h" do
    it "returns the original hash" do
      expect(obj.to_h).to eq(hash)
    end
  end

  describe "#respond_to?" do
    it "returns true for defined keys" do
      expect(obj).to respond_to(:id)
      expect(obj).to respond_to(:key)
    end

    it "returns false for missing keys" do
      expect(obj).not_to respond_to(:missing)
    end
  end

  describe "method_missing" do
    it "raises NoMethodError for undefined keys" do
      expect { obj.nonexistent }.to raise_error(NoMethodError)
    end
  end

  describe "#==" do
    it "equals another ObjectifiedHash with the same data" do
      expect(obj).to eq(described_class.new(hash))
    end

    it "equals the original hash" do
      expect(obj).to eq(hash)
    end
  end
end
