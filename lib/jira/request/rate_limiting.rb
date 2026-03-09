# frozen_string_literal: true

module Jira
  class Request
    # Implements Jira Cloud rate-limit retry policy.
    #
    # Follows the official Atlassian guidance:
    # https://developer.atlassian.com/cloud/jira/platform/rate-limiting/
    #
    # Supported response headers (enforced by Jira Cloud):
    #   Retry-After        — seconds to wait before retrying (429 and some 503)
    #   X-RateLimit-Reset  — ISO 8601 timestamp when the window resets (429 only)
    #   X-RateLimit-Limit  — max request rate for the current scope
    #   X-RateLimit-Remaining — remaining capacity in the current window
    #   X-RateLimit-NearLimit — "true" when < 20% capacity remains
    #   RateLimit-Reason   — which limit was exceeded (burst/quota/per-issue)
    class RetryPolicy
      IDEMPOTENT_HTTP_METHODS = %w[get head put delete options].freeze

      # Unix timestamp threshold: values above this are epoch seconds, not second-counts.
      UNIX_TIMESTAMP_THRESHOLD = 1_000_000_000

      # Jitter range recommended by Atlassian docs: multiply backoff by factor in [0.7, 1.3].
      JITTER_RANGE = (0.7..1.3)

      def initialize(request:, rand_proc: method(:rand))
        @request = request
        @rand_proc = rand_proc
      end

      def sleep_before_retry(response:, retries_left:)
        sleep(wait_seconds(response: response, retries_left: retries_left))
      end

      def retryable?(error:, method:, response:, retries_left:)
        return false if retries_left <= 1
        return false unless IDEMPOTENT_HTTP_METHODS.include?(method.to_s)
        return true if error.is_a?(Jira::Error::TooManyRequests)

        response_has_rate_limit_hint?(response)
      end

      def wait_seconds(response:, retries_left:)
        retry_after = parse_retry_after(response)
        return retry_after if retry_after

        reset_delay = parse_rate_limit_reset(response)
        return reset_delay if reset_delay

        exponential_backoff_wait(retries_left)
      end

      private

      # Retry-After: integer seconds (e.g. "5").
      def parse_retry_after(response)
        value = response&.headers&.[]("Retry-After")
        return nil unless value

        parse_seconds_or_timestamp(value)
      end

      # X-RateLimit-Reset: ISO 8601 timestamp (e.g. "2024-01-15T10:30:00.000Z").
      # Also accepts RateLimit-Reset as fallback.
      def parse_rate_limit_reset(response)
        value = response&.headers&.[]("X-RateLimit-Reset") || response&.headers&.[]("RateLimit-Reset")
        return nil unless value

        seconds = parse_seconds_or_timestamp(value)
        return nil if seconds.nil?

        [seconds, 0.0].max
      end

      # Parses a header value that can be:
      #   - integer seconds:      "5"
      #   - Unix epoch timestamp: "1705314600"
      #   - ISO 8601 datetime:    "2024-01-15T10:30:00.000Z"  (Jira Cloud standard)
      #   - HTTP date:            "Mon, 15 Jan 2024 10:30:00 GMT"
      def parse_seconds_or_timestamp(value)
        numeric = Float(value)
        return numeric if numeric < UNIX_TIMESTAMP_THRESHOLD

        [numeric - Time.now.to_f, 0.0].max
      rescue ArgumentError, TypeError
        parse_datetime_string(value.to_s)
      end

      def parse_datetime_string(value)
        [Time.iso8601(value).to_f - Time.now.to_f, 0.0].max
      rescue ArgumentError
        begin
          [Time.httpdate(value).to_f - Time.now.to_f, 0.0].max
        rescue ArgumentError
          nil
        end
      end

      # Exponential backoff with proportional jitter, per Atlassian recommendations:
      # base_delay * 2^attempt, capped at max_delay, multiplied by rand(0.7..1.3).
      def exponential_backoff_wait(retries_left)
        retry_attempt = ratelimit_retries - retries_left
        backoff = [ratelimit_base_delay * (2**retry_attempt), ratelimit_max_delay].min
        jitter_factor = @rand_proc.call(JITTER_RANGE)
        [backoff * jitter_factor, ratelimit_max_delay].min
      end

      def response_has_rate_limit_hint?(response)
        headers = response&.headers || {}
        headers.key?("Retry-After") || headers.key?("X-RateLimit-Reset") || headers.key?("RateLimit-Reset")
      end

      def ratelimit_retries
        @request.ratelimit_retries || Configuration::DEFAULT_RATELIMIT_RETRIES
      end

      def ratelimit_base_delay
        @request.ratelimit_base_delay || Configuration::DEFAULT_RATELIMIT_BASE_DELAY
      end

      def ratelimit_max_delay
        @request.ratelimit_max_delay || Configuration::DEFAULT_RATELIMIT_MAX_DELAY
      end
    end
  end
end
