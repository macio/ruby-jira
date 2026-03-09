# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::API do
  subject(:api) do
    described_class.new(
      endpoint:  "https://jira.atlassian.net",
      auth_type: :basic,
      email:     "user@example.com",
      api_token: "secret"
    )
  end

  describe ".default_options[:headers]" do
    it "has User-Agent" do
      api
      expect(described_class.default_options[:headers]).to include("User-Agent" => Jira::Configuration::DEFAULT_USER_AGENT)
    end
  end
end
