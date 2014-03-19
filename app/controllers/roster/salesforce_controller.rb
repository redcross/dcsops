class Roster::SalesforceController < ApplicationController
  def new
    url = current_chapter.salesforce_sso_url
    unless url.present?
      render text: "Salesforce SSO is not configured for this chapter.", status: 500
      return
    end

    start_params = {startURL: params[:RelayState]}

    redirect_to "#{url}?#{start_params.to_query}"
  end
end