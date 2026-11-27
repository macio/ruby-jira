# frozen_string_literal: true

require "live_helper"

# Membership writes (add_user_to_group, remove_user_from_group) are not run live:
# they change site-wide access, not data in the TEST project.
RSpec.describe Jira::Client do
  let(:group_name) do
    Jira.myself(expand: "groups")[:groups][:items].map { |group| group[:name] }.find { |n| n.start_with?("jira-users") }
  end

  describe ".group" do
    it "returns a group of the current user by name", :aggregate_failures do
      result = record_fixture("group") { Jira.group(group_name) }

      expect(result[:name]).to eq(group_name)
      expect(result[:groupId]).to be_a(String)
    end
  end

  describe ".group_members" do
    it "returns members as a paginated response" do
      result = record_fixture("group_members") { Jira.group_members(group_name, maxResults: 5) }

      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.first[:accountId]).to be_a(String)
    end
  end
end
