# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".audit_records" do
    it "passes date and paging options and returns the records", :aggregate_failures do
      stub_get("/auditing/record?from=2026-11-01&limit=1000&offset=0", "audit_records.json")

      result = Jira.audit_records(from: "2026-11-01", offset: 0, limit: 1000)

      expect(a_get("/auditing/record?from=2026-11-01&limit=1000&offset=0")).to have_been_made
      expected = fixture_json("audit_records")
      expect(result[:records].first[:summary]).to eq(expected["records"].first["summary"])
      expect(result[:total]).to eq(expected["total"])
    end
  end
end
