# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::ADF do
  describe ".from_text" do
    it "wraps a single line in one paragraph" do
      expect(described_class.from_text("Hello")).to eq(
        version: 1,
        type:    "doc",
        content: [{ type: "paragraph", content: [{ type: "text", text: "Hello" }] }]
      )
    end

    it "splits blank-line separated blocks into paragraphs" do
      doc = described_class.from_text("First\n\nSecond")

      expect(doc[:content].map { |p| p[:content].first[:text] }).to eq(%w[First Second])
    end

    it "turns a single newline into a hardBreak node" do
      expect(described_class.from_text("a\nb")[:content].first).to eq(
        type:    "paragraph",
        content: [
          { type: "text", text: "a" },
          { type: "hardBreak" },
          { type: "text", text: "b" }
        ]
      )
    end

    it "returns a document with no content for empty input" do
      expect(described_class.from_text("")).to eq(version: 1, type: "doc", content: [])
      expect(described_class.from_text(nil)).to eq(version: 1, type: "doc", content: [])
    end

    it "never produces empty text nodes" do
      nodes = described_class.from_text("a\n\n\n\nb\n")[:content].flat_map { |p| p[:content] }

      expect(nodes).to all(satisfy { |n| n[:type] != "text" || !n[:text].empty? })
    end
  end
end
