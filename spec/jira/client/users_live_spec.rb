# frozen_string_literal: true

require "live_helper"

RSpec.describe Jira::Client do
  let(:me) { Jira.myself }

  describe ".myself" do
    it "returns the current user with groups", :aggregate_failures do
      result = record_fixture("myself") { Jira.myself(expand: "groups") }

      expect(result).to be_a(Jira::ObjectifiedHash)
      expect(result[:accountId]).to be_a(String)
      expect(result[:displayName]).to be_a(String)
      expect(result.dig(:groups, :items)).to be_an(Array)
    end
  end

  describe ".user" do
    it "returns a user by account ID" do
      result = record_fixture("user") { Jira.user(me[:accountId]) }

      expect(result[:accountId]).to eq(me[:accountId])
    end
  end

  describe ".user_search" do
    it "finds the current user by display name", :aggregate_failures do
      result = record_fixture("user_search") { Jira.user_search(me[:displayName]) }

      expect(result).to be_an(Array)
      expect(result.map { |user| user[:accountId] }).to include(me[:accountId])
    end
  end

  describe ".user_assignable_search" do
    it "returns users assignable in the test project", :aggregate_failures do
      result = record_fixture("user_assignable_search") { Jira.user_assignable_search(project: Jira::Live::PROJECT_KEY) }

      expect(result).to be_an(Array)
      expect(result.first[:accountId]).to be_a(String)
    end
  end
end
