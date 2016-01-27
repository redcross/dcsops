module Omniauth
  class Request
    def host_and_port
      uri = URI.parse(resource) rescue nil
      if uri.try(:host).present?
        [uri.host, [80].include?(uri.port) ? nil : uri.port]
      else
        scheme_or_host, host_or_port, port_or_nil = resource.split('@').last.split('/').first.split(':')
        case host_or_port
        when nil, /\d+/
          [scheme_or_host, host_or_port.try(:to_i)]
        else
          [host_or_port, port_or_nil.try(:to_i)]
        end
      end
    end
  end
end

if Rails.env.development?
  WebFinger.http_config do |client|
    client.ssl_config.add_trust_ca("/usr/local/etc/openssl/certs/ca-bundle.crt")
    client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
 provider :openid_connect, {
    name: :rco,
    scope: [:openid, :email],
    response_type: :code,
    issuer: ENV["RCO_DOMAIN"],
    client_options: {
      port: 443,
      scheme: "https",
      host: ENV["RCO_DOMAIN"],
      identifier: ENV["RCO_CLIENT_ID"],
      secret: ENV["RCO_CLIENT_SECRET"],
      authorization_endpoint: "/as/authorization.oauth2",
      token_endpoint: "/as/token.oauth2",
      userinfo_endpoint: "/idp/userinfo.openid",
      jwks_uri: "/pf/JWKS",
      discovery: false
    },
  }
end