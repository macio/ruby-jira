# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".group" do
    it "returns a group by name", :aggregate_failures do
      stub_get("/group?groupname=jira-developers", "group.json")

      result = Jira.group("jira-developers")

      expect(a_get("/group?groupname=jira-developers")).to have_been_made
      expect(result.groupId).to eq("abc-123")
    end
  end

  describe ".group_members" do
    it "returns members as a paginated response", :aggregate_failures do
      stub_get("/group/member?groupname=jira-developers", "group_members.json")

      result = Jira.group_members("jira-developers")

      expect(a_get("/group/member?groupname=jira-developers")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.first[:accountId]).to eq("5b10ac8d82e05b22cc7d4ef5")
    end
  end

  describe ".add_user_to_group" do
    it "posts the account ID with the group name in the query", :aggregate_failures do
      stub_post("/group/user?groupname=jira-developers", "group.json", status_code: 201)

      Jira.add_user_to_group("jira-developers", "5b10ac8d82e05b22cc7d4ef5")

      expect(
        a_post("/group/user?groupname=jira-developers")
                .with(body: { accountId: "5b10ac8d82e05b22cc7d4ef5" }.to_json)
      ).to have_been_made
    end
  end

  describe ".remove_user_from_group" do
    let(:remove_url) do
      "#{Jira.endpoint}/rest/api/3/group/user?accountId=5b10ac8d82e05b22cc7d4ef5&groupname=jira-developers"
    end

    it "deletes the membership with name and account ID in the query" do
      stub_request(:delete, remove_url)
        .with(headers: { "Authorization" => basic_authorization_value })
        .to_return(status: 200, body: "")

      Jira.remove_user_from_group("jira-developers", "5b10ac8d82e05b22cc7d4ef5")

      expect(a_request(:delete, remove_url)).to have_been_made
    end
  end
end
