module OauthController
  extend ActiveSupport::Concern

  def oauth2_api_user
    header = env['HTTP_AUTHORIZATION']
    return unless header
    pp header
    (type, token) = header.split ' '
    if type.downcase == 'bearer'
      return ApiClient.for_app_secret token
    end
    return nil
  end

  def oauth_api_user
    return @oauth_api_user if defined?(@oauth_api_user)

    req = OAuth::RequestProxy::RackRequest.new(request)
    return nil unless req.parameters['oauth_consumer_key']

    client = ApiClient.for_app_token req.parameters['oauth_consumer_key']
    return nil unless client

    begin
      signature = ::OAuth::Signature.build(::Rack::Request.new(env)) do |rp|
        [nil, client.app_secret]
      end

      return @oauth_api_user=client if signature.verify
    rescue ::OAuth::Signature::UnknownSignatureMethod => e
      logger.error 'Unknown signature method', e
    end
    return nil
  end
end
