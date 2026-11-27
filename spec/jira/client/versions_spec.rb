# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".create_version" do
    it "posts the version payload", :aggregate_failures do
      stub_post("/version", "create_version.json", status_code: 201)
      payload = fixture_json("create_version_request")

      result = Jira.create_version(payload)

      expect(a_post("/version").with(body: payload)).to have_been_made
      expect(result.name).to eq(fixture_json("create_version")["name"])
    end
  end

  describe ".version" do
    it "returns a version by ID" do
      stub_get("/version/10000", "version.json")

      expect(Jira.version(10_000).id).to eq(fixture_json("version")["id"])
    end
  end

  describe ".update_version" do
    it "puts the changed fields to the version", :aggregate_failures do
      stub_put("/version/10000", "update_version.json")
      payload = fixture_json("update_version_request")

      result = Jira.update_version(10_000, payload)

      expect(a_put("/version/10000").with(body: payload)).to have_been_made
      expect(result.released).to eq(fixture_json("update_version")["released"])
    end
  end

  describe ".delete_version" do
    it "deletes a version" do
      stub_request(:delete, "#{Jira.endpoint}/rest/api/3/version/10000")
        .with(headers: { "Authorization" => basic_authorization_value })
        .to_return(status: 204, body: "")

      Jira.delete_version(10_000)

      expect(a_request(:delete, "#{Jira.endpoint}/rest/api/3/version/10000")).to have_been_made
    end
  end

  describe ".project_versions" do
    it "returns all versions of a project as an array", :aggregate_failures do
      stub_get("/project/TEST/versions", "project_versions.json")

      result = Jira.project_versions("TEST")

      expect(a_get("/project/TEST/versions")).to have_been_made
      expect(result.map(&:name)).to eq(fixture_json("project_versions").map { |version| version["name"] })
    end
  end
end
