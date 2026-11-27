# frozen_string_literal: true

module Jira
  # Builds Atlassian Document Format (ADF) documents from plain text.
  #
  # Jira v3 expects ADF for rich-text fields such as issue descriptions and comment bodies.
  #
  # @url https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/
  module ADF
    class << self
      # Converts plain text into an ADF document.
      #
      # Blank lines separate paragraphs. A single newline inside a paragraph becomes a hardBreak node.
      # Empty input produces a document with no content.
      #
      # @param text [String, nil] Plain text
      # @return [Hash] ADF document with :version, :type and :content keys
      def from_text(text)
        {
          version: 1,
          type:    "doc",
          content: text.to_s.split(/\n{2,}/).map(&:strip).reject(&:empty?).map { |paragraph| paragraph_node(paragraph) }
        }
      end

      private

      def paragraph_node(text)
        { type: "paragraph", content: inline_nodes(text) }
      end

      def inline_nodes(text)
        lines = text.split("\n", -1)
        lines.each_with_index.flat_map do |line, index|
          nodes = line.empty? ? [] : [{ type: "text", text: line }]
          index < lines.size - 1 ? nodes + [{ type: "hardBreak" }] : nodes
        end
      end
    end
  end
end
