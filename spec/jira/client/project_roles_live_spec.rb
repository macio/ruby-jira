# frozen_string_literal: true

require "live_helper"

RSpec.describe Jira::Client do
  let(:roles) { record_fixture("project_roles") { Jira.project_roles(Jira::Live::PROJECT_KEY) } }

  describe ".project_roles" do
    it "returns a map of role names to role URLs" do
      expect(roles.to_h.values).to all(match(%r{/project/\d+/role/\d+\z}))
    end
  end

  describe ".project_role" do
    it "returns a role with its actors", :aggregate_failures do
      name, url = roles.to_h.find { |role_name, _| role_name.to_s.start_with?("Administrator") }
      id = url[%r{/role/(\d+)\z}, 1]

      result = record_fixture("project_role") { Jira.project_role(Jira::Live::PROJECT_KEY, id) }

      expect(result[:name]).to eq(name.to_s)
      expect(result[:actors]).not_to be_empty
    end
  end
end
