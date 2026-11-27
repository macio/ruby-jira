# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".my_filters" do
    it "returns filters as an array", :aggregate_failures do
      stub_get("/filter/my?expand=description", "my_filters.json")

      result = Jira.my_filters(expand: "description")

      expect(a_get("/filter/my?expand=description")).to have_been_made
      expect(result.map(&:name)).to eq(["My open bugs", "Sprint board"])
    end
  end

  describe ".filter" do
    it "returns a filter by ID", :aggregate_failures do
      stub_get("/filter/10000", "filter.json")

      result = Jira.filter(10_000)

      expect(a_get("/filter/10000")).to have_been_made
      expect(result.jql).to include("currentUser()")
    end
  end

  describe ".filter_search" do
    it "returns filters as a paginated response", :aggregate_failures do
      stub_get("/filter/search?filterName=bugs", "filter_search.json")

      result = Jira.filter_search(filterName: "bugs")

      expect(a_get("/filter/search?filterName=bugs")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.first[:id]).to eq("10000")
    end
  end
end
