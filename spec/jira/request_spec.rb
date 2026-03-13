# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Request do
  subject(:request) { described_class.new }

  before do
    request.endpoint = "https://jira.atlassian.net"
    request.auth_type = :basic
    request.email = "user@example.com"
    request.api_token = "token"
    request.oauth_client_id = nil
    request.oauth_client_secret = nil
    request.oauth_refresh_token = nil
    request.oauth_grant_type = nil
    request.oauth_token_endpoint = Jira::Configuration::DEFAULT_OAUTH_TOKEN_ENDPOINT
    request.ratelimit_retries = 3
    request.ratelimit_base_delay = 1.0
    request.ratelimit_max_delay = 10.0
  end

  describe ".default_options" do
    it "has expected defaults" do
      default_options = described_class.default_options

      expect(default_options[:format]).to eq(:json)
      expect(default_options[:headers]).to eq(
        "Accept" => "application/json",
        "Content-Type" => "application/json"
      )
      expect(default_options[:parser]).to be_a(Proc)
    end
  end

  describe ".parse" do
    it "returns hash for object response" do
      body = JSON.generate(a: 1, b: 2)

      expect(described_class.parse(body)).to be_a(Jira::ObjectifiedHash)
      expect(described_class.parse(body)[:a]).to eq(1)
    end

    it "returns paginated response for offset payload" do
      body = JSON.generate(isLast: true, total: 1, values: [])

      expect(described_class.parse(body)).to be_a(Jira::PaginatedResponse)
    end
  end

  describe "#request_defaults" do
    it "raises when endpoint is missing" do
      request.endpoint = nil

      expect do
        request.request_defaults
      end.to raise_error(Jira::Error::MissingCredentials, "Please set an endpoint to API")
    end

    it "raises for unsupported auth type" do
      request.auth_type = :token

      expect { request.request_defaults }
        .to raise_error(Jira::Error::MissingCredentials, "Unsupported auth_type 'token'. Use :basic or :oauth2")
    end

    it "raises when basic email is missing" do
      request.email = nil

      expect { request.request_defaults }
        .to raise_error(Jira::Error::MissingCredentials, "Please provide email for :basic auth")
    end

    it "raises when oauth2 token is missing" do
      request.auth_type = :oauth2
      request.oauth_access_token = nil
      request.cloud_id = "cloud-1"

      expect { request.request_defaults }
        .to raise_error(
          Jira::Error::MissingCredentials,
          Jira::Request::OAUTH_MISSING_CREDENTIALS_MESSAGE
        )
    end
  end

  describe "#authorization_header" do
    it "builds basic auth header" do
      header = request.send(:authorization_header)

      expect(header).to eq("Authorization" => "Basic dXNlckBleGFtcGxlLmNvbTp0b2tlbg==")
    end

    it "builds oauth2 bearer header" do
      request.auth_type = :oauth2
      request.oauth_access_token = "oauth-token"
      request.cloud_id = "cloud-1"

      header = request.send(:authorization_header)

      expect(header).to eq("Authorization" => "Bearer oauth-token")
    end

    context "when refreshing oauth token from client credentials" do
      before do
        request.auth_type = :oauth2
        request.oauth_access_token = nil
        request.oauth_client_id = "client-id"
        request.oauth_client_secret = "client-secret"
        request.oauth_refresh_token = "refresh-token"
        request.oauth_grant_type = "refresh_token"
        request.cloud_id = "cloud-1"

        stub_request(:post, Jira::Configuration::DEFAULT_OAUTH_TOKEN_ENDPOINT)
          .with(
            body:    {
              grant_type:    "refresh_token",
              client_id:     "client-id",
              client_secret: "client-secret",
              refresh_token: "refresh-token"
            }.to_json,
            headers: {
              "Accept" => "application/json",
              "Content-Type" => "application/json"
            }
          )
          .to_return(
            status: 200,
            body:   {
              access_token:  "refreshed-token",
              expires_in:    3600,
              refresh_token: "rotated-refresh-token"
            }.to_json
          )
      end

      it "returns bearer header with refreshed token", :aggregate_failures do
        header = request.send(:authorization_header)

        expect(header).to eq("Authorization" => "Bearer refreshed-token")
        expect(request.oauth_access_token).to eq("refreshed-token")
        expect(request.oauth_refresh_token).to eq("rotated-refresh-token")
        expect(request.oauth_access_token_expires_at).to be > Time.now
      end
    end

    context "when getting oauth token with client_credentials grant" do
      before do
        request.auth_type = :oauth2
        request.oauth_access_token = nil
        request.oauth_client_id = "client-id"
        request.oauth_client_secret = "client-secret"
        request.oauth_refresh_token = nil
        request.oauth_grant_type = "client_credentials"
        request.cloud_id = "cloud-1"

        stub_request(:post, Jira::Configuration::DEFAULT_OAUTH_TOKEN_ENDPOINT)
          .with(
            body:    {
              grant_type:    "client_credentials",
              client_id:     "client-id",
              client_secret: "client-secret"
            }.to_json,
            headers: {
              "Accept" => "application/json",
              "Content-Type" => "application/json"
            }
          )
          .to_return(status: 200, body: { access_token: "service-token", expires_in: 3600 }.to_json)
      end

      it "returns bearer header with service token", :aggregate_failures do
        header = request.send(:authorization_header)

        expect(header).to eq("Authorization" => "Bearer service-token")
        expect(request.oauth_access_token).to eq("service-token")
        expect(request.oauth_refresh_token).to be_nil
        expect(request.oauth_access_token_expires_at).to be > Time.now
      end
    end
  end

  describe "HTTP request methods" do
    it "builds basic URL from endpoint" do
      path = "https://jira.atlassian.net/rest/api/3/project/TEST"
      stub_request(:get, path).to_return(status: 200, body: "{}")

      request.get("/project/TEST")

      expect(
        a_request(:get, path).with(
          headers: {
            "Authorization" => "Basic dXNlckBleGFtcGxlLmNvbTp0b2tlbg=="
          }.merge(described_class.headers)
        )
      ).to have_been_made
    end

    it "builds oauth2 URL with cloud_id" do
      request.auth_type = :oauth2
      request.oauth_access_token = "oauth-token"
      request.cloud_id = "cloud-1"
      path = "https://api.atlassian.com/ex/jira/cloud-1/rest/api/3/project/TEST"
      stub_request(:get, path).to_return(status: 200, body: "{}")

      request.get("/project/TEST")

      expect(
        a_request(:get, path).with(
          headers: {
            "Authorization" => "Bearer oauth-token"
          }.merge(described_class.headers)
        )
      ).to have_been_made
    end

    it "serializes hash body to json" do
      path = "https://jira.atlassian.net/rest/api/3/issue"
      payload = { fields: { summary: "New issue" } }

      stub_request(:post, path).to_return(status: 200, body: "{}")
      request.post("/issue", body: payload)

      expect(a_request(:post, path).with(body: payload.to_json)).to have_been_made
    end
  end

  describe "pagination fetchers" do
    let(:search_path) { "https://jira.atlassian.net/rest/api/3/search" }
    let(:search_jql_path) { "https://jira.atlassian.net/rest/api/3/search/jql" }
    let(:offset_first_page) do
      { startAt: 0, maxResults: 1, total: 2, issues: [{ id: "10001", key: "ED-1", fields: {} }] }
    end
    let(:offset_second_page) do
      { startAt: 1, maxResults: 1, total: 2, issues: [{ id: "10002", key: "ED-2", fields: {} }] }
    end
    let(:cursor_first_page) { { nextPageToken: "token-123", isLast: false, issues: [{ id: "10001" }] } }
    let(:cursor_second_page) { { isLast: true, issues: [{ id: "10002" }] } }

    it "continues offset pagination for POST by injecting startAt into body", :aggregate_failures do
      stub_request(:post, search_path)
        .with { |request_body| JSON.parse(request_body.body).fetch("startAt", nil).nil? }
        .to_return(status: 200, body: JSON.generate(offset_first_page))
      stub_request(:post, search_path)
        .with { |request_body| JSON.parse(request_body.body).fetch("startAt", nil) == 1 }
        .to_return(status: 200, body: JSON.generate(offset_second_page))

      result = request.post("/search", body: { jql: "project = EX", maxResults: 1 })
      all = result.auto_paginate

      expect(all.map { |issue| issue[:key] }).to eq(%w[ED-1 ED-2])
      expect(a_request(:post, search_path)).to have_been_made.twice
    end

    it "continues cursor pagination for POST by injecting nextPageToken into body", :aggregate_failures do
      stub_request(:post, search_jql_path)
        .with { |request_body| JSON.parse(request_body.body).fetch("nextPageToken", nil).nil? }
        .to_return(status: 200, body: JSON.generate(cursor_first_page))
      stub_request(:post, search_jql_path)
        .with { |request_body| JSON.parse(request_body.body).fetch("nextPageToken", nil) == "token-123" }
        .to_return(status: 200, body: JSON.generate(cursor_second_page))

      result = request.post("/search/jql", body: { jql: "project = EX" })
      all = result.auto_paginate

      expect(all.map { |issue| issue[:id] }).to eq(%w[10001 10002])
      expect(a_request(:post, search_jql_path)).to have_been_made.twice
    end
  end

  describe "rate limiting" do
    let(:path) { "https://jira.atlassian.net/rest/api/3/project/TEST" }
    let(:sleeping_policy) { instance_double(Jira::Request::RetryPolicy) }

    before do
      request.instance_variable_set(:@retry_policy, sleeping_policy)
      allow(sleeping_policy).to receive(:retryable?).and_return(true, true, false)
      allow(sleeping_policy).to receive(:wait_seconds).and_return(0)
      allow(sleeping_policy).to receive(:sleep_before_retry)
    end

    it "retries idempotent requests on 429 with Retry-After seconds" do
      stub_request(:get, path).to_return(status: 429, headers: { "Retry-After" => "5" })

      expect { request.get("/project/TEST") }.to raise_error(Jira::Error::TooManyRequests)
      expect(a_request(:get, path)).to have_been_made.times(3)
      expect(sleeping_policy).to have_received(:sleep_before_retry).twice
    end

    it "retries on 429 with X-RateLimit-Reset as ISO 8601 timestamp" do
      reset_time = (Time.now + 10).iso8601
      stub_request(:get, path).to_return(status: 429, headers: { "X-RateLimit-Reset" => reset_time })

      expect { request.get("/project/TEST") }.to raise_error(Jira::Error::TooManyRequests)
      expect(a_request(:get, path)).to have_been_made.times(3)
      expect(sleeping_policy).to have_received(:sleep_before_retry).twice
    end

    it "retries on 503 with X-RateLimit-Reset as integer seconds" do
      stub_request(:get, path).to_return(status: 503, headers: { "X-RateLimit-Reset" => "3" }, body: "{}")

      expect { request.get("/project/TEST") }.to raise_error(Jira::Error::ServiceUnavailable)
      expect(a_request(:get, path)).to have_been_made.times(3)
      expect(sleeping_policy).to have_received(:sleep_before_retry).twice
    end

    it "does not retry non-idempotent requests on 429" do
      allow(sleeping_policy).to receive(:retryable?).and_return(false)
      stub_request(:post, "https://jira.atlassian.net/rest/api/3/issue").to_return(status: 429, body: "{}")

      expect { request.post("/issue", body: { fields: { summary: "A" } }) }.to raise_error(Jira::Error::TooManyRequests)
      expect(a_request(:post, "https://jira.atlassian.net/rest/api/3/issue")).to have_been_made.once
      expect(sleeping_policy).not_to have_received(:sleep_before_retry)
    end

    it "does not retry 503 without rate-limit headers" do
      allow(sleeping_policy).to receive(:retryable?).and_return(false)
      stub_request(:get, path).to_return(status: 503, body: "{}")

      expect { request.get("/project/TEST") }.to raise_error(Jira::Error::ServiceUnavailable)
      expect(a_request(:get, path)).to have_been_made.once
      expect(sleeping_policy).not_to have_received(:sleep_before_retry)
    end

    it "falls back to exponential backoff with proportional jitter" do
      # retries=2, base_delay=1.0, retry_attempt=1 => backoff=2.0, jitter=1.0 => sleep(2.0)
      request.ratelimit_retries = 2
      fixed_rand = ->(_range) { 1.0 }
      real_policy = Jira::Request::RetryPolicy.new(request: request, rand_proc: fixed_rand)
      spy_policy = instance_double(Jira::Request::RetryPolicy)
      allow(spy_policy).to receive(:retryable?) do |**kwargs|
        real_policy.retryable?(**kwargs)
      end
      allow(spy_policy).to receive(:wait_seconds) do |**kwargs|
        real_policy.wait_seconds(**kwargs)
      end

      slept_values = []
      allow(spy_policy).to receive(:sleep_before_retry) do |response:, retries_left:|
        slept_values << real_policy.wait_seconds(response: response, retries_left: retries_left)
      end

      request.instance_variable_set(:@retry_policy, spy_policy)

      stub_request(:get, path).to_return(status: 429, body: "{}")

      expect { request.get("/project/TEST") }.to raise_error(Jira::Error::TooManyRequests)
      expect(slept_values).to include(be_within(0.001).of(2.0))
    end

    it "respects max_delay cap on backoff" do
      request.ratelimit_retries = 3
      request.ratelimit_base_delay = 1.0
      request.ratelimit_max_delay = 3.0
      fixed_rand = ->(_range) { 1.3 }
      real_policy = Jira::Request::RetryPolicy.new(request: request, rand_proc: fixed_rand)
      spy_policy = instance_double(Jira::Request::RetryPolicy)

      slept_values = []
      allow(spy_policy).to receive(:retryable?) do |**kwargs|
        real_policy.retryable?(**kwargs)
      end
      allow(spy_policy).to receive(:wait_seconds) do |**kwargs|
        real_policy.wait_seconds(**kwargs)
      end
      allow(spy_policy).to receive(:sleep_before_retry) do |response:, retries_left:|
        slept_values << real_policy.wait_seconds(response: response, retries_left: retries_left)
      end

      request.instance_variable_set(:@retry_policy, spy_policy)

      stub_request(:get, path).to_return(status: 429, body: "{}")

      expect { request.get("/project/TEST") }.to raise_error(Jira::Error::TooManyRequests)
      # first retry: backoff=2.0*1.3=2.6; second retry: backoff capped at 3.0, jitter 3.0*1.3=3.9 also capped => 3.0
      expect(slept_values).to include(be_within(0.001).of(3.0))
    end
  end
end
