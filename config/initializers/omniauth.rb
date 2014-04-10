Rails.application.config.middleware.use OmniAuth::Builder do
  unless Rails.env.production?
    provider :developer, :fields => [:first_name, :last_name, :email]
  end

  provider :developer unless Rails.env.production?

  google = OpenProject::Configuration["openid_connect"]["google"]
  provider :openid_connect,
    :name => :google,
    :scope => [:openid, :email, :profile],
    :client_auth_method => :not_basic,
    :callback_request_method => :POST,
    :send_nonce => false,
    :client_options => {
      :port => 443,
      :scheme => "https",
      :host => "accounts.google.com",
      :authorization_endpoint => "/o/oauth2/auth",
      :token_endpoint => "/o/oauth2/token",
      :userinfo_endpoint => "https://www.googleapis.com/plus/v1/people/me/openIdConnect",

      :identifier => google["identifier"],
      :secret => google["secret"],
      :redirect_uri => "http://localhost:3000/auth/google/callback"
    }
end
