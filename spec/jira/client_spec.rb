# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe "#inspect" do
    context "with basic auth" do
      subject(:inspected_client) do
        described_class.new(
          endpoint:  "https://jira.atlassian.net",
          auth_type: :basic,
          email:     "user@example.com",
          api_token: "abcdefgh"
        ).inspect
      end

      it "masks api_token" do
        expect(inspected_client).to include('@api_token="****efgh"')
        expect(inspected_client).not_to include('api_token="abcdefgh"')
      end
    end

    context "with oauth2 auth" do
      subject(:inspected_client) do
        described_class.new(
          endpoint:            "https://jira.atlassian.net",
          auth_type:           :oauth2,
          oauth_access_token:  "oauthsecrettoken",
          oauth_client_secret: "super-secret-client",
          oauth_refresh_token: "super-secret-refresh",
          cloud_id:            "cloud-1"
        ).inspect
      end

      it "masks oauth_access_token", :aggregate_failures do
        expect(inspected_client).to match(/@oauth_access_token="\*+oken"/)
        expect(inspected_client).not_to include('oauth_access_token="oauthsecrettoken"')
        expect(inspected_client).to match(/@oauth_client_secret="\*+ient"/)
        expect(inspected_client).not_to include('oauth_client_secret="super-secret-client"')
        expect(inspected_client).to match(/@oauth_refresh_token="\*+resh"/)
        expect(inspected_client).not_to include('oauth_refresh_token="super-secret-refresh"')
      end
    end
  end
end
