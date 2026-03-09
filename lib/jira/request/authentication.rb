# frozen_string_literal: true

module Jira
  class Request
    class OAuthTokenClient
      TOKEN_ENDPOINT_HEADERS = {
        "Accept" => "application/json",
        "Content-Type" => "application/json"
      }.freeze

      def initialize(request:)
        @request = request
      end

      def fetch!(payload)
        response = HTTParty.post(token_endpoint, **request_options(payload))
        body = JSON.parse(response.body.to_s, symbolize_names: true)
        return body if response.code.to_i.between?(200, 299)

        message = body[:error_description] || body[:error] || response.body
        raise Error::MissingCredentials, "OAuth token refresh failed: #{message}"
      rescue JSON::ParserError
        raise Error::MissingCredentials, "OAuth token refresh failed: invalid JSON response"
      end

      private

      def token_endpoint
        @request.oauth_token_endpoint || Configuration::DEFAULT_OAUTH_TOKEN_ENDPOINT
      end

      # Build HTTParty options, forwarding any proxy config set on Jira::Request.
      def request_options(payload)
        opts = { body: payload.to_json, headers: TOKEN_ENDPOINT_HEADERS }
        proxy = proxy_options
        opts.merge!(proxy) if proxy.any?
        opts
      end

      def proxy_options
        defaults = Jira::Request.default_options
        {
          http_proxyaddr: defaults[:http_proxyaddr],
          http_proxyport: defaults[:http_proxyport],
          http_proxyuser: defaults[:http_proxyuser],
          http_proxypass: defaults[:http_proxypass]
        }.compact
      end
    end

    class Authenticator
      OAUTH_TOKEN_EXPIRY_BUFFER = 30
      SUPPORTED_OAUTH_GRANT_TYPES = %w[client_credentials refresh_token].freeze
      OAUTH_MISSING_CREDENTIALS_MESSAGE = [
        "Please provide oauth_access_token or",
        "oauth_client_id/oauth_client_secret (and oauth_refresh_token for refresh_token grant) for :oauth2 auth"
      ].join(" ").freeze

      def initialize(request:, token_client: OAuthTokenClient.new(request: request))
        @request = request
        @token_client = token_client
      end

      def auth_type
        type = (@request.auth_type || Configuration::DEFAULT_AUTH_TYPE).to_sym
        return type if %i[basic oauth2].include?(type)

        raise Error::MissingCredentials, "Unsupported auth_type '#{type}'. Use :basic or :oauth2"
      end

      def validate!
        case auth_type
        when :basic
          validate_basic_auth!
        when :oauth2
          validate_oauth2_auth!
        end
      end

      def authorization_header
        case auth_type
        when :basic
          validate_basic_auth!
          credentials = Base64.strict_encode64("#{@request.email}:#{@request.api_token}")
          { "Authorization" => "Basic #{credentials}" }
        when :oauth2
          validate_oauth2_auth!
          { "Authorization" => "Bearer #{oauth_access_token!}" }
        end
      end

      private

      def validate_basic_auth!
        raise Error::MissingCredentials, "Please provide email for :basic auth" if @request.email.to_s.strip.empty?
        return unless @request.api_token.to_s.strip.empty?

        raise Error::MissingCredentials, "Please provide api_token for :basic auth"
      end

      def validate_oauth2_auth!
        if !oauth_access_token_available? && !oauth_client_credentials_available?
          raise Error::MissingCredentials, OAUTH_MISSING_CREDENTIALS_MESSAGE
        end
        return unless @request.cloud_id.to_s.strip.empty?

        raise Error::MissingCredentials, "Please provide cloud_id for :oauth2 auth"
      end

      def oauth_access_token_available?
        !@request.oauth_access_token.to_s.strip.empty?
      end

      def oauth_client_credentials_available?
        return false if @request.oauth_client_id.to_s.strip.empty? || @request.oauth_client_secret.to_s.strip.empty?
        return true if oauth_grant_type == "client_credentials"

        !@request.oauth_refresh_token.to_s.strip.empty?
      end

      def oauth_access_token!
        return @request.oauth_access_token if oauth_access_token_valid?
        return refresh_oauth_access_token! if oauth_client_credentials_available?

        raise Error::MissingCredentials, OAUTH_MISSING_CREDENTIALS_MESSAGE
      end

      def oauth_access_token_valid?
        return false unless oauth_access_token_available?
        return true if @request.oauth_access_token_expires_at.nil?

        Time.now < @request.oauth_access_token_expires_at
      end

      def refresh_oauth_access_token!
        body = @token_client.fetch!(refresh_token_payload)
        apply_oauth_tokens!(body)
        @request.oauth_access_token
      end

      def refresh_token_payload
        payload = {
          grant_type:    oauth_grant_type,
          client_id:     @request.oauth_client_id,
          client_secret: @request.oauth_client_secret
        }
        return payload if oauth_grant_type == "client_credentials"

        payload.merge(refresh_token: @request.oauth_refresh_token)
      end

      def apply_oauth_tokens!(body)
        token = body[:access_token]
        raise Error::MissingCredentials, "OAuth token endpoint did not return access_token" if token.to_s.strip.empty?

        @request.oauth_access_token = token
        @request.oauth_refresh_token = body[:refresh_token] if body[:refresh_token]
        update_oauth_expiry(body[:expires_in])
      end

      def update_oauth_expiry(expires_in)
        return if expires_in.to_i <= 0

        @request.oauth_access_token_expires_at = Time.now + [expires_in.to_i - OAUTH_TOKEN_EXPIRY_BUFFER, 0].max
      end

      def oauth_grant_type
        type = @request.oauth_grant_type.to_s.strip
        return "refresh_token" if type.empty? && !@request.oauth_refresh_token.to_s.strip.empty?
        return "client_credentials" if type.empty?

        unless SUPPORTED_OAUTH_GRANT_TYPES.include?(type)
          raise Error::MissingCredentials, "Unsupported oauth_grant_type '#{type}'"
        end

        type
      end
    end
  end
end
