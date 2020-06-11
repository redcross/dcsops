require "openid"
require "openid/consumer/discovery"
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/extensions/ax'
require 'openid/store/memcache'
require 'openid/store/filesystem'

class Roster::OpenIdController < ApplicationController
  include OpenID::Server
  layout nil

  skip_before_action :require_valid_user!
  skip_before_action :verify_authenticity_token

  rescue_from ProtocolError do |ex|
    render :text => ex.to_s, :status => 500
  end

  def service
    @types = [OpenID::OPENID_IDP_2_0_TYPE]

    render :action => :services
  end

  def user
    @types = [OpenID::OPENID_2_0_TYPE,
             OpenID::OPENID_1_0_TYPE,
             OpenID::SREG_URI]
    render :action => :services
  end

  def endpoint
    if session[:openid_request]
      oidreq = session[:openid_request]
      session[:openid_request] = nil
    else
      oidreq = server.decode_request(params)
    end

    unless oidreq #  no openid.mode was given
      render :text => "This is an OpenID server endpoint."
      return
    end

    oidresp = nil

    if oidreq.kind_of?(CheckIDRequest)

      identity = oidreq.identity

      if oidreq.id_select
        if oidreq.immediate
          oidresp = oidreq.answer(false)
        elsif current_user_session.nil?
          session[:openid_request] = oidreq
          require_valid_user!(roster_openid_endpoint_url) # should trigger the redirect
          return
        else
          # Else, set the identity to the one the user is using.
          identity = user_url(current_user)
        end
      end

      if oidresp
        nil
      elsif user_url(current_user)==identity # TODO: Check that this is a trusted root or ask for permission
        oidresp = oidreq.answer(true, nil, identity)

        # add the sreg response if requested
        # add_sreg(oidreq, oidresp)
        # ditto pape
        # add_pape(oidreq, oidresp)

        add_ax(oidreq, oidresp, current_user)

      elsif oidreq.immediate
        oidresp = oidreq.answer(false, roster_openid_endpoint_url)

      else # User is logged in but we don't trust this root or the request or something
        #show_decision_page(oidreq)
        return
      end

    else
      oidresp = server.handle_request(oidreq)
    end

    render_response(oidresp)
  end

  private

  def user_url(user)
    roster_openid_user_url(user_id: user)
  end

  def add_ax(req, resp, user)
    axreq = OpenID::AX::FetchRequest.from_openid_request(req)
    unless axreq.nil?
      axresp = OpenID::AX::FetchResponse.new
      axreq.requested_types.each do |t|
        val = case t
        when "http://axschema.org/namePerson/first" then user.first_name
        when "http://axschema.org/namePerson/last" then user.last_name
        when "http://axschema.org/contact/email" then user.email
        else nil
        end

        if val
          axresp.set_values(t, [val])
        end
      end
      resp.add_extension(axresp)
    end
  end

  def store
    if Rails.env.production?
      OpenID::Store::Memcache.new Rails.cache.dalli
    else
      dir = File.join(Rails.root, 'tmp', 'openid-store')
      store = OpenID::Store::Filesystem.new(dir)
    end
  end

  def server
    if @server.nil?
      server_url = roster_openid_endpoint_url
      @server = Server.new(store, server_url)
    end
    return @server
  end

  def render_response(oidresp)
    if oidresp.needs_signing
      signed_response = server.signatory.sign(oidresp)
    end
    web_response = server.encode_response(oidresp)

    case web_response.code
    when HTTP_OK
      render :text => web_response.body, :status => 200

    when HTTP_REDIRECT
      redirect_to web_response.headers['location']

    else
      render :text => web_response.body, :status => 400
    end
  end
end