# frozen_string_literal: true

require "json"
require "uri"
require "webmock"
require_relative "sanitizer"

module Jira
  module Live
    # Records the last HTTP exchange made inside a block as sanitized fixtures:
    #   spec/fixtures/<name>.json          - response body
    #   spec/fixtures/<name>_request.json  - request body (only for JSON requests)
    #
    # Uses WebMock callbacks, so it works with real requests (live specs) and, with
    # `real_only: false`, with stubbed requests (unit specs of this helper).
    module FixtureRecorder
      FIXTURES_DIR = File.expand_path("../../fixtures", __dir__)
      SLOTS = { true => :jira_live_recorder_real, false => :jira_live_recorder_any }.freeze

      class NothingRecordedError < StandardError; end

      def self.install!
        return if @installed

        WebMock.after_request(real_requests_only: true) { |request, response| capture(SLOTS[true], request, response) }
        WebMock.after_request { |request, response| capture(SLOTS[false], request, response) }
        @installed = true
      end

      def self.capture(slot, request, response)
        holder = Thread.current[slot]
        holder[:exchange] = [request, response] if holder
      end

      def self.write(name, exchange, dir:, host:, email:)
        request, response = exchange
        body = response&.body.to_s
        raise NothingRecordedError, "No response with a body was recorded for #{name}" if body.empty?

        write_json(File.join(dir, "#{name}.json"), body, host: host, email: email)

        request_body = request.body.to_s
        return unless request_body.start_with?("{", "[")

        write_json(File.join(dir, "#{name}_request.json"), request_body, host: host, email: email)
      end

      def self.write_json(path, json, host:, email:)
        data = Sanitizer.call(JSON.parse(json), host: host, email: email)
        File.write(path, "#{JSON.pretty_generate(data)}\n")
      end

      def self.instance_host
        URI(ENV.fetch("JIRA_ENDPOINT", "")).host
      end

      def record_fixture(name, real_only: true, dir: FIXTURES_DIR, host: FixtureRecorder.instance_host,
        email: ENV.fetch("JIRA_EMAIL", nil))
        FixtureRecorder.install!
        slot = SLOTS.fetch(real_only)
        holder = {}
        Thread.current[slot] = holder
        result = yield
        FixtureRecorder.write(name, holder[:exchange], dir: dir, host: host, email: email)
        result
      ensure
        Thread.current[slot] = nil
      end
    end
  end
end
