# frozen_string_literal: true

require "live_helper"

RSpec.describe Jira::Client do
  let(:scope) { Jira::Live::RunScope.new(project: Jira::Live::PROJECT_KEY) }
  let(:project_id) { Jira.project(Jira::Live::PROJECT_KEY)[:id].to_i }

  after { scope.cleanup! }

  it "creates, reads, updates, lists and deletes a version", :aggregate_failures do
    name = "#{scope.prefix} version"
    created = record_fixture("create_version") { Jira.create_version(name: name, projectId: project_id) }
    id = created[:id]
    scope.on_cleanup("version #{id}") { Jira.delete_version(id) }

    fetched = record_fixture("version") { Jira.version(id) }
    updated = record_fixture("update_version") { Jira.update_version(id, released: true, releaseDate: "2026-01-15") }
    listed = record_fixture("project_versions") { Jira.project_versions(Jira::Live::PROJECT_KEY) }

    expect(created[:name]).to eq(name)
    expect(fetched[:projectId]).to eq(project_id)
    expect(updated[:released]).to be(true)
    expect(updated[:releaseDate]).to eq("2026-01-15")
    expect(listed.map { |version| version[:id] }).to include(id)

    Jira.delete_version(id)
    expect { Jira.version(id) }.to raise_error(Jira::Error::NotFound)
  end
end
