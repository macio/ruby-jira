# frozen_string_literal: true

module Jira
  class Request
    class UrlBuilder
      OAUTH_API_BASE = "https://api.atlassian.com/ex/jira"
      PLATFORM_API_PATH = "/rest/api/3"

      def initialize(request:, authenticator:)
        @request = request
        @authenticator = authenticator
      end

      def build(path)
        "#{api_base_url}#{normalize_path(path)}"
      end

      def api_request_path
        URI.parse(api_base_url).request_uri
      end

      private

      def api_base_url
        case @authenticator.auth_type
        when :basic
          "#{normalized_endpoint}#{PLATFORM_API_PATH}"
        when :oauth2
          "#{OAUTH_API_BASE}/#{@request.cloud_id}#{PLATFORM_API_PATH}"
        end
      end

      def normalized_endpoint
        @request.endpoint.to_s.delete_suffix("/")
      end

      def normalize_path(path)
        string_path = path.to_s
        string_path.start_with?("/") ? string_path : "/#{string_path}"
      end
    end

    class ParamsBuilder
      def initialize(request:, authenticator:)
        @request = request
        @authenticator = authenticator
      end

      def build(options)
        params = options.dup
        merge_httparty_config!(params)
        add_authorization_header!(params) unless params[:unauthenticated]
        serialize_json_body!(params)
        params
      end

      private

      def merge_httparty_config!(params)
        params.merge!(@request.httparty) if @request.httparty
      end

      def add_authorization_header!(params)
        params[:headers] ||= {}
        params[:headers].merge!(@authenticator.authorization_header)
      end

      def serialize_json_body!(params)
        return unless params[:body].is_a?(Hash)
        return if params[:multipart] == true

        params[:headers] ||= {}
        params[:headers]["Content-Type"] ||= "application/json"
        params[:body] = params[:body].to_json
      end
    end
  end
end
