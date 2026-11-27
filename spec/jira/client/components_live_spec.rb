# frozen_string_literal: true

require "live_helper"

RSpec.describe Jira::Client do
  let(:scope) { Jira::Live::RunScope.new(project: Jira::Live::PROJECT_KEY) }

  after { scope.cleanup! }

  it "creates, reads, updates, lists and deletes a component", :aggregate_failures do
    name = "#{scope.prefix} component"
    created = record_fixture("create_component") do
      Jira.create_component(name: name, project: Jira::Live::PROJECT_KEY)
    end
    id = created[:id]
    scope.on_cleanup("component #{id}") { Jira.delete_component(id) }

    fetched = record_fixture("component") { Jira.component(id) }
    updated = record_fixture("update_component") { Jira.update_component(id, description: "Server-side code") }
    listed = record_fixture("project_components") { Jira.project_components(Jira::Live::PROJECT_KEY) }

    expect(created[:name]).to eq(name)
    expect(fetched[:project]).to eq(Jira::Live::PROJECT_KEY)
    expect(updated[:description]).to eq("Server-side code")
    expect(listed.map { |component| component[:id] }).to include(id)

    Jira.delete_component(id)
    expect { Jira.component(id) }.to raise_error(Jira::Error::NotFound)
  end
end
