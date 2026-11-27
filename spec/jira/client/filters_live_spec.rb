# frozen_string_literal: true

require "live_helper"

# The gem has no filter write methods, so the filter is created and deleted through the raw client.
RSpec.describe Jira::Client do
  let(:scope) { Jira::Live::RunScope.new(project: Jira::Live::PROJECT_KEY) }
  let(:jql) { "project = #{Jira::Live::PROJECT_KEY} ORDER BY created DESC" }

  after { scope.cleanup! }

  it "reads a filter owned by the current user", :aggregate_failures do
    name = "#{scope.prefix} filter"
    id = Jira.client.post("/filter", body: { name: name, jql: jql })[:id]
    scope.on_cleanup("filter #{id}") { Jira.client.delete("/filter/#{id}") }

    mine = record_fixture("my_filters") { Jira.my_filters(expand: "description") }
    fetched = record_fixture("filter") { Jira.filter(id) }
    found = record_fixture("filter_search") { Jira.filter_search(filterName: name) }

    expect(mine.map { |filter| filter[:id] }).to include(id)
    expect(fetched[:jql]).to eq(jql)
    expect(found).to be_a(Jira::PaginatedResponse)
    expect(found.map { |filter| filter[:id] }).to include(id)
  end
end
