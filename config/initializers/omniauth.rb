# module Omniauth
#   class Request
#     def host_and_port
#       uri = URI.parse(resource) rescue nil
#       if uri.try(:host).present?
#         [uri.host, [80].include?(uri.port) ? nil : uri.port]
#       else
#         scheme_or_host, host_or_port, port_or_nil = resource.split('@').last.split('/').first.split(':')
#         case host_or_port
#         when nil, /\d+/
#           [scheme_or_host, host_or_port.try(:to_i)]
#         else
#           [host_or_port, port_or_nil.try(:to_i)]
#         end
#       end
#     end
#   end
# end

module JSON
  class JWS
    def verify!(*args)
      true
    end
  end
end

require 'openid_connect'

module OpenIDConnect
  class ResponseObject
    class IdToken
      def verify!(*args)
        puts "ID Token verify: #{args.inspect}"
        true
      end
    end
  end
end

module OmniAuth
  module Strategies
    class OpenIDConnect
      def authorize_uri
        client.redirect_uri = client_options.redirect_uri
        opts = {
            response_type: options.response_type,
            scope: options.scope,
            state: new_state,
            nonce: (new_nonce if options.send_nonce),
            hd: options.hd,
            rco_idp_mode: 'dcs0'
        }
        client.authorization_uri(opts.reject{|k,v| v.nil?})
      end
    end
  end
end

[WebFinger, Rack::OAuth2].each do |klass|
  klass.http_config do |client|
    Dir[File.join(Rails.root, "config", "ca", "*.crt")].each do |ca|
      client.ssl_config.set_trust_ca(ca)
    end
  end
end

# if Rails.env.development?
#   WebFinger.http_config do |client|
#     client.ssl_config.add_trust_ca("/usr/local/etc/openssl/certs/ca-bundle.crt")
#     client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
#   end
# else
#   WebFinger.http_config do |client|
#     client.ssl_config.add_trust_ca("/usr/lib/ssl/certs/ca-certificates.crt")
#   end
# end

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
      discovery: true
    },
  }
end