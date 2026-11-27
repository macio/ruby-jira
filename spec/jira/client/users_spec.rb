# frozen_string_literal: true

require "spec_helper"

# Fixtures are recorded by users_live_spec.rb (rake live); assertions read values from them.
RSpec.describe Jira::Client do
  def fixture_json(name)
    JSON.parse(load_fixture(name).read)
  end

  describe ".myself" do
    it "returns the current user", :aggregate_failures do
      stub_get("/myself", "myself")
      expected = fixture_json("myself")

      result = Jira.myself

      expect(a_get("/myself")).to have_been_made
      expect(result).to be_a(Jira::ObjectifiedHash)
      expect(result[:accountId]).to eq(expected["accountId"])
      expect(result.displayName).to eq(expected["displayName"])
    end

    it "passes query options" do
      stub_get("/myself?expand=groups", "myself")

      Jira.myself(expand: "groups")

      expect(a_get("/myself?expand=groups")).to have_been_made
    end
  end

  describe ".user" do
    it "returns a user by account ID", :aggregate_failures do
      account_id = fixture_json("user")["accountId"]
      stub_get("/user?accountId=#{account_id}", "user")

      result = Jira.user(account_id)

      expect(a_get("/user?accountId=#{account_id}")).to have_been_made
      expect(result[:accountId]).to eq(account_id)
    end
  end

  describe ".user_search" do
    it "searches users by query", :aggregate_failures do
      stub_get("/user/search?query=test", "user_search")

      result = Jira.user_search("test")

      expect(a_get("/user/search?query=test")).to have_been_made
      expect(result).to be_an(Array)
      expect(result.map { |user| user[:accountId] }).to eq(fixture_json("user_search").map { |user| user["accountId"] })
    end
  end

  describe ".user_assignable_search" do
    it "returns assignable users for a project", :aggregate_failures do
      stub_get("/user/assignable/search?project=TEST", "user_assignable_search")

      result = Jira.user_assignable_search(project: "TEST")

      expect(a_get("/user/assignable/search?project=TEST")).to have_been_made
      expect(result).to be_an(Array)
      expect(result.size).to eq(fixture_json("user_assignable_search").size)
    end
  end
end
