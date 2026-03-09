# frozen_string_literal: true

require "spec_helper"

TestObject = Struct.new(:message, :error_description, :error, :embed_entity, :password)

class FakeResponse
  attr_accessor :code, :parsed_response, :request, :body, :headers, :options, :error_code

  def initialize(attrs = {})
    @code = attrs[:code]
    @parsed_response = attrs[:parsed_response]
    @request = attrs[:request]
    @body = attrs[:body]
    @headers = attrs.fetch(:headers, {})
    @options = attrs.fetch(:options, {})
    @error_code = attrs[:error_code]
  end

  def to_s = @body.to_s
end

RSpec.describe Jira::Error::ResponseError do
  let(:request_double) do
    Struct.new(:base_uri, :path, :options).new("https://jira.atlassian.net/api/v3", "/foo", {})
  end

  let(:expected_messages) do
    [
      %r{Server responded with code \d+, message: Displayed message. Request URI: https://jira.atlassian.net/api/v3/foo},
      %r{Server responded with code \d+, message: Displayed error_description. Request URI: https://jira.atlassian.net/api/v3/foo},
      %r{Server responded with code \d+, message: Displayed error. Request URI: https://jira.atlassian.net/api/v3/foo},
      %r{Server\ responded\ with\ code\ \d+,\ message:\ 'embed_entity'\ \(foo:\ bar\)\ \(sna:\ fu\),
         \ 'password'\ too\ short.\ Request\ URI:\ https://jira.atlassian.net/api/v3/foo}x,
      %r{Server responded with code \d+, message: First message. Second message.. Request URI: https://jira.atlassian.net/api/v3/foo},
      %r{Server responded with code \d+, message: 'error' Spam detected. Request URI: https://jira.atlassian.net/api/v3/foo}
    ]
  end

  # Set up some response scenarios to test.
  [
    { code:            401,
      parsed_response: TestObject.new(
        message:           "Displayed message",
        error_description: "should not be displayed",
        error:             "also will not be displayed"
      ) },
    { code:            404,
      parsed_response: TestObject.new(
        error_description: "Displayed error_description",
        error:             "also will not be displayed"
      ) },
    { code:            401,
      parsed_response: TestObject.new(error: "Displayed error") },
    { code:            500,
      parsed_response: TestObject.new(embed_entity: { foo: ["bar"], sna: ["fu"] }, password: ["too short"]) },
    { code:            403,
      parsed_response: ["First message.", "Second message."] },
    { code:            400,
      parsed_response: TestObject.new(message: { error: "Spam detected" }) }

  ].each_with_index do |data, index|
    it "returns the expected message" do
      response_double = FakeResponse.new(**data, request: request_double)
      expect(described_class.new(response_double).message).to match expected_messages[index]
    end
  end

  it "builds an error message from text" do
    headers = { "content-type" => "text/plain" }
    response_double = FakeResponse.new(
      body:            "Retry text",
      parsed_response: { message: "Retry hash" },
      code:            429,
      options:         {},
      headers:         headers,
      request:         request_double
    )
    expect(described_class.new(response_double).send(:build_error_message)).to match(/Retry text/)
  end

  it "builds an error message from parsed json" do
    headers = { "content-type" => "application/json" }
    response_double = FakeResponse.new(
      body:            "Retry later",
      parsed_response: { message: "Retry hash" },
      code:            429,
      options:         {},
      headers:         headers,
      request:         request_double
    )
    expect(described_class.new(response_double).send(:build_error_message)).to match(/Retry hash/)
  end

  describe "parsing errors" do
    let(:headers) { { "content-type" => "application/json" } }
    let(:response_double) do
      FakeResponse.new(
        body:    "Retry text",
        code:    status,
        options: {},
        headers: headers,
        request: request_double
      )
    end
    let(:status) { 429 }

    before do
      allow(response_double).to receive(:parsed_response)
        .and_raise(Jira::Error::Parsing)
    end

    it "builds an error message from text" do
      expect(described_class.new(response_double).send(:build_error_message)).to match(/Retry text/)
    end
  end

  describe "#error_code" do
    it "returns the value when available" do
      headers = { "content-type" => "application/json" }
      response_double = FakeResponse.new(
        body:            "Retry later",
        parsed_response: { message: "Retry hash" },
        code:            400,
        error_code:      "conflict",
        options:         {},
        headers:         headers,
        request:         request_double
      )

      expect(described_class.new(response_double).error_code).to eq "conflict"
    end

    it "returns nothing when unavailable" do
      response_without_error_code = Struct.new(:code, :parsed_response, :request, :body, :headers, :options) do
        def to_s = body.to_s
      end.new(
        400,
        { message: "Retry hash" },
        request_double,
        "Retry later",
        { "content-type" => "application/json" },
        {}
      )

      expect(described_class.new(response_without_error_code).error_code).to eq ""
    end
  end
end
