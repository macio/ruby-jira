# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".issue_security_level_scheme" do
    it "gets issue security level scheme for a project", :aggregate_failures do
      stub_get("/project/TEST/issuesecuritylevelscheme", "issue_security_level_scheme")

      scheme = Jira.issue_security_level_scheme("TEST")

      expect(a_get("/project/TEST/issuesecuritylevelscheme")).to have_been_made
      expect(scheme[:id]).to eq(10_000)
      expect(scheme[:name]).to eq("Default Issue Security Scheme")
      expect(scheme[:levels].length).to eq(1)
      expect(scheme[:levels].first[:name]).to eq("Reporter Only")
    end

    it "passes query options" do
      stub_get("/project/TEST/issuesecuritylevelscheme?expand=levels", "issue_security_level_scheme")
      Jira.issue_security_level_scheme("TEST", expand: "levels")

      expect(a_get("/project/TEST/issuesecuritylevelscheme?expand=levels")).to have_been_made
    end
  end

  describe ".permission_scheme" do
    it "gets assigned permission scheme for a project", :aggregate_failures do
      stub_get("/project/TEST/permissionscheme", "permission_scheme")

      scheme = Jira.permission_scheme("TEST")

      expect(a_get("/project/TEST/permissionscheme")).to have_been_made
      expect(scheme[:id]).to eq(10_000)
      expect(scheme[:name]).to eq("Example permission scheme")
    end

    it "passes query options" do
      stub_get("/project/TEST/permissionscheme?expand=permissions", "permission_scheme")
      Jira.permission_scheme("TEST", expand: "permissions")

      expect(a_get("/project/TEST/permissionscheme?expand=permissions")).to have_been_made
    end
  end

  describe ".assign_permission_scheme" do
    it "assigns permission scheme by scheme_id", :aggregate_failures do
      stub_put("/project/TEST/permissionscheme", "permission_scheme_assigned")

      scheme = Jira.assign_permission_scheme("TEST", scheme_id: 10_000)

      expect(a_put("/project/TEST/permissionscheme").with(body: { id: 10_000 }.to_json)).to have_been_made
      expect(scheme[:id]).to eq(10_000)
      expect(scheme[:name]).to eq("Example permission scheme")
    end

    it "merges additional options into body" do
      stub_put("/project/TEST/permissionscheme", "permission_scheme_assigned")

      Jira.assign_permission_scheme("TEST", scheme_id: 10_000, options: { expand: "permissions" })

      expect(
        a_put("/project/TEST/permissionscheme")
                .with(body: { id: 10_000, expand: "permissions" }.to_json)
      ).to have_been_made
    end
  end
end
