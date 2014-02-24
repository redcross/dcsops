module OauthController
  extend ActiveSupport::Concern

  def oauth2_api_user
    header = env['HTTP_AUTHORIZATION']
    return unless header
    (type, token) = header.split ' '
    if type.downcase == 'bearer'
      return ApiClient.for_app_secret token
    end
    return nil
  end

end
