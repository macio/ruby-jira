# frozen_string_literal: true

require "live_helper"

RSpec.describe Jira::Client do
  describe ".audit_records" do
    it "returns records with paging fields", :aggregate_failures do
      result = record_fixture("audit_records") { Jira.audit_records(offset: 0, limit: 5) }

      expect(result[:records]).to be_an(Array)
      expect(result[:limit]).to eq(5)
      expect(result[:total]).to be_an(Integer)
    end
  end
end
