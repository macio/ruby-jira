# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  enable_coverage :branch
  add_filter "/spec/"
  minimum_coverage line: 88, branch: 60
end

require "base64"
require "jira"
require "webmock/rspec"

def load_fixture(name)
  fixture_name, extension = name.split(".", 2)
  File.new(File.dirname(__FILE__) + "/fixtures/#{fixture_name}.#{extension || "json"}")
end

def basic_authorization_value(email = Jira.email, api_token = Jira.api_token)
  credentials = Base64.strict_encode64("#{email}:#{api_token}")
  "Basic #{credentials}"
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.before(:all) do
    Jira.endpoint = "https://jira.atlassian.net"
    Jira.auth_type = :basic
    Jira.email = "user@example.com"
    Jira.api_token = "secret"
    Jira.oauth_access_token = nil
    Jira.cloud_id = nil
  end
end

%i[get post put delete patch].each do |method|
  define_method "stub_#{method}" do |path, fixture, status_code: 200|
    stub_request(method, "#{Jira.endpoint}/rest/api/3#{path}")
      .with(headers: {
        "Accept" => "application/json",
        "Authorization" => basic_authorization_value,
        "Content-Type" => "application/json"
      }
           )
      .to_return(body: load_fixture(fixture), status: status_code)
  end

  define_method "a_#{method}" do |path|
    a_request(method, "#{Jira.endpoint}/rest/api/3#{path}")
      .with(headers: {
        "Accept" => "application/json",
        "Authorization" => basic_authorization_value,
        "Content-Type" => "application/json"
      }
           )
  end

  define_method "stub_agile_#{method}" do |path, fixture, status_code: 200|
    stub_request(method, "#{Jira.endpoint}/rest/agile/1.0#{path}")
      .with(headers: {
        "Accept" => "application/json",
        "Authorization" => basic_authorization_value,
        "Content-Type" => "application/json"
      }
           )
      .to_return(body: load_fixture(fixture), status: status_code)
  end

  define_method "a_agile_#{method}" do |path|
    a_request(method, "#{Jira.endpoint}/rest/agile/1.0#{path}")
      .with(headers: {
        "Accept" => "application/json",
        "Authorization" => basic_authorization_value,
        "Content-Type" => "application/json"
      }
           )
  end
end
