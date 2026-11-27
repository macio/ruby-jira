# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".create_version" do
    it "posts the version payload", :aggregate_failures do
      stub_post("/version", "version.json", status_code: 201)

      result = Jira.create_version(name: "1.0", projectId: 10_000)

      expect(a_post("/version")).to have_been_made
      expect(result.name).to eq("1.0")
    end
  end

  describe ".version" do
    it "returns a version by ID" do
      stub_get("/version/10000", "version.json")

      expect(Jira.version(10_000).id).to eq("10000")
    end
  end

  describe ".update_version" do
    it "puts the changed fields to the version" do
      stub_put("/version/10000", "version.json")

      Jira.update_version(10_000, released: true)

      expect(a_put("/version/10000")).to have_been_made
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
      expect(result.map(&:name)).to eq(%w[1.0 2.0])
    end
  end
end
