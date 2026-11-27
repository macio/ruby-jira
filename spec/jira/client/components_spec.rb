# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".create_component" do
    it "posts the component payload", :aggregate_failures do
      stub_post("/component", "component.json", status_code: 201)

      result = Jira.create_component(name: "Backend", project: "TEST")

      expect(a_post("/component")).to have_been_made
      expect(result.name).to eq("Backend")
    end
  end

  describe ".component" do
    it "returns a component by ID" do
      stub_get("/component/10000", "component.json")

      expect(Jira.component(10_000).project).to eq("TEST")
    end
  end

  describe ".update_component" do
    it "puts the changed fields to the component" do
      stub_put("/component/10000", "component.json")

      Jira.update_component(10_000, description: "Server-side code")

      expect(a_put("/component/10000")).to have_been_made
    end
  end

  describe ".delete_component" do
    it "deletes a component" do
      stub_request(:delete, "#{Jira.endpoint}/rest/api/3/component/10000")
        .with(headers: { "Authorization" => basic_authorization_value })
        .to_return(status: 204, body: "")

      Jira.delete_component(10_000)

      expect(a_request(:delete, "#{Jira.endpoint}/rest/api/3/component/10000")).to have_been_made
    end
  end

  describe ".project_components" do
    it "returns all components of a project as an array", :aggregate_failures do
      stub_get("/project/TEST/components", "project_components.json")

      result = Jira.project_components("TEST")

      expect(a_get("/project/TEST/components")).to have_been_made
      expect(result.map(&:name)).to eq(%w[Backend Frontend])
    end
  end
end
