# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".myself" do
    it "returns the current user", :aggregate_failures do
      stub_get("/myself", "myself.json")

      result = Jira.myself

      expect(a_get("/myself")).to have_been_made
      expect(result[:accountId]).to eq("5b10a2844c20165700ede21g")
      expect(result.displayName).to eq("Test User")
    end
  end

  describe ".user" do
    it "returns a user by account ID", :aggregate_failures do
      stub_get("/user?accountId=5b10ac8d82e05b22cc7d4ef5", "user.json")

      result = Jira.user("5b10ac8d82e05b22cc7d4ef5")

      expect(a_get("/user?accountId=5b10ac8d82e05b22cc7d4ef5")).to have_been_made
      expect(result.displayName).to eq("Mia Krystof")
    end
  end

  describe ".user_search" do
    it "searches users by query", :aggregate_failures do
      stub_get("/user/search?query=mia", "user_search.json")

      result = Jira.user_search("mia")

      expect(a_get("/user/search?query=mia")).to have_been_made
      expect(result.first[:accountId]).to eq("5b10ac8d82e05b22cc7d4ef5")
    end
  end

  describe ".user_assignable_search" do
    it "returns assignable users for a project", :aggregate_failures do
      stub_get("/user/assignable/search?project=ED", "user_search.json")

      result = Jira.user_assignable_search(project: "ED")

      expect(a_get("/user/assignable/search?project=ED")).to have_been_made
      expect(result.first.displayName).to eq("Mia Krystof")
    end
  end
end
