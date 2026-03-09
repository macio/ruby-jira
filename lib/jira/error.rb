# frozen_string_literal: true

module Jira
  module Error
    # Base class for all Jira errors.
    class Base < StandardError; end

    # Raised when API endpoint credentials not configured.
    class MissingCredentials < Base; end

    # Raised when impossible to parse response body.
    class Parsing < Base; end

    # Custom error class for rescuing from HTTP response errors.
    class ResponseError < Base
      POSSIBLE_MESSAGE_KEYS = %i[message error_description error].freeze

      def initialize(response)
        @response = response
        super(build_error_message)
      end

      # Status code returned in the HTTP response.
      #
      # @return [Integer]
      def response_status
        @response.code
      end

      # Body content returned in the HTTP response
      #
      # @return [String]
      def response_message
        parsed_response = @response.parsed_response
        return parsed_response[:message] || parsed_response["message"] if parsed_response.is_a?(Hash)

        parsed_response.respond_to?(:message) ? parsed_response.message : parsed_response
      end

      # Additional error context returned by some API endpoints
      #
      # @return [String]
      def error_code
        if @response.respond_to?(:error_code)
          @response.error_code
        else
          ""
        end
      end

      private

      # Human friendly message.
      #
      # @return [String]
      def build_error_message
        parsed_response = classified_response
        message = check_error_keys(parsed_response)
        "Server responded with code #{@response.code}, message: " \
          "#{handle_message(message)}. " \
          "Request URI: #{@response.request.base_uri}#{@response.request.path}"
      end

      # Error keys vary across the API, find the first available key and return it.
      def check_error_keys(response)
        return hash_message(response) if response.is_a?(Hash)

        object_message(response)
      end

      # Parse the body based on the classification of the body content type.
      #
      # @return [Object]
      def classified_response
        if @response.respond_to?(:headers)
          @response.headers["content-type"] == "text/plain" ? { message: @response.to_s } : @response.parsed_response
        else
          @response.parsed_response
        end
      rescue Jira::Error::Parsing
        @response.to_s
      end

      # Handle error response message in case of nested hashes.
      def handle_message(message)
        case message
        when Hash
          message.to_h.sort.map do |key, value|
            "'#{key}' #{formatted_hash_value(value)}"
          end.join(", ")
        when Array
          message.join(" ")
        else
          message
        end
      end

      def formatted_hash_value(value)
        if value.is_a?(Hash)
          value.sort.map { |key, nested_value| "(#{key}: #{Array(nested_value).join(" ")})" }.join(" ")
        else
          Array(value).join(" ")
        end
      end

      def present_value?(value)
        return false if value.nil?
        return !value.empty? if value.respond_to?(:empty?)

        true
      end

      def hash_message(response)
        POSSIBLE_MESSAGE_KEYS.each do |key|
          symbol_value = response[key]
          return symbol_value if present_value?(symbol_value)

          string_value = response[key.to_s]
          return string_value if present_value?(string_value)
        end

        response
      end

      def object_message(response)
        POSSIBLE_MESSAGE_KEYS.each do |candidate|
          next unless response.respond_to?(candidate)

          value = response.send(candidate)
          return value if present_value?(value)
        end

        compact_hash_response(response) || response
      end

      def compact_hash_response(response)
        return nil if response.is_a?(Array) || !response.respond_to?(:to_h)

        hash_response = response.to_h.compact
        hash_response.empty? ? nil : hash_response
      end
    end

    # Raised when API endpoint returns the HTTP status code 400.
    class BadRequest < ResponseError; end

    # Raised when API endpoint returns the HTTP status code 401.
    class Unauthorized < ResponseError; end

    # Raised when API endpoint returns the HTTP status code 403.
    class Forbidden < ResponseError; end

    # Raised when API endpoint returns the HTTP status code 404.
    class NotFound < ResponseError; end

    # Raised when API endpoint returns the HTTP status code 405.
    class MethodNotAllowed < ResponseError; end

    # Raised when API endpoint returns the HTTP status code 406.
    class NotAcceptable < ResponseError; end

    # Raised when API endpoint returns the HTTP status code 409.
    class Conflict < ResponseError; end

    # Raised when API endpoint returns the HTTP status code 422.
    class Unprocessable < ResponseError; end

    # Raised when API endpoint returns the HTTP status code 429.
    class TooManyRequests < ResponseError; end

    # Raised when API endpoint returns the HTTP status code 500.
    class InternalServerError < ResponseError; end

    # Raised when API endpoint returns the HTTP status code 502.
    class BadGateway < ResponseError; end

    # Raised when API endpoint returns the HTTP status code 503.
    class ServiceUnavailable < ResponseError; end

    # Raised when API endpoint returns the HTTP status code 522.
    class ConnectionTimedOut < ResponseError; end

    STATUS_MAPPINGS = {
      400 => BadRequest,
      401 => Unauthorized,
      403 => Forbidden,
      404 => NotFound,
      405 => MethodNotAllowed,
      406 => NotAcceptable,
      409 => Conflict,
      422 => Unprocessable,
      429 => TooManyRequests,
      500 => InternalServerError,
      502 => BadGateway,
      503 => ServiceUnavailable,
      522 => ConnectionTimedOut
    }.freeze

    # Returns error class that should be raised for this response. Returns nil
    # if the response status code is not 4xx or 5xx.
    #
    # @param response [HTTParty::Response] The response object.
    # @return [Class<Jira::Error::ResponseError>, nil]
    def self.klass(response)
      error_klass = STATUS_MAPPINGS[response.code]
      return error_klass if error_klass

      ResponseError if response.server_error? || response.client_error?
    end
  end
end
