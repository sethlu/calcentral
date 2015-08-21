module GoogleApps
  class CredentialStore

    def initialize(options = {})
      @options = options
    end

    def load_credentials
      app_name = @options[:app_name]
      google_configs = Settings.google_proxy.marshal_dump
      if app_name.nil?
        # Use default client credentials
        credentials = google_configs
      else
        # Custom clients can be configured via YAML convention: google_proxy.my_app.client_id, etc.
        key = app_name.to_sym
        credentials = google_configs[key].marshal_dump if google_configs.has_key? key
      end
      unless credentials.nil?
        credentials[:token_credential_uri] = 'https://accounts.google.com/o/oauth2/token'
        # Token override
        credentials[:access_token] = @options[:access_token] if @options.has_key? :access_token
        credentials[:refresh_token] = @options[:refresh_token] if @options.has_key? :refresh_token
      end
      credentials
    end

    def write_credentials(credentials_hash = {})
      # Per http://google-api-python-client.googlecode.com/hg/docs/epy/oauth2client.file.Storage-class.html
      # Our implementation does not cache (i.e., serialize) OAuth 2 tokens on disk.
      # See Google::APIClient::FileStore for an alternate strategy.
    end

  end
end
