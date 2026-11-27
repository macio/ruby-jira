# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".project_roles" do
    it "returns the role name to URL map" do
      stub_get("/project/TEST/role", "project_roles.json")

      expect(Jira.project_roles("TEST")[:Administrators]).to eq(fixture_json("project_roles")["Administrators"])
    end
  end

  describe ".project_role" do
    it "returns a role with its actors", :aggregate_failures do
      stub_get("/project/TEST/role/10001", "project_role.json")

      result = Jira.project_role("TEST", 10_001)

      expect(a_get("/project/TEST/role/10001")).to have_been_made
      expected = fixture_json("project_role")
      expect(result[:name]).to eq(expected["name"])
      expect(result[:actors].first[:type]).to eq(expected["actors"].first["type"])
    end
  end
end
