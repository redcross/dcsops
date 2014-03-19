class UnauthenticatedRequestFilter

  def self.arity
    1
  end

  def self.call req
    rack_req = Rack::Request.new req.env
    rack_req.instance_eval do
      def request; self; end
      def remote_ip; self.ip; end
    end
    Authlogic::Session::Base.controller = Authlogic::ControllerAdapters::AbstractAdapter.new(rack_req)
    ret = Roster::Session.find.nil?
    Authlogic::Session::Base.controller = nil
    if ret
      req.env['SET_RETURN_TO'] = '/'
    end
    ret
  end

  class AuthenticatedRequestFilter < UnauthenticatedRequestFilter

    def self.call req
      !super(req)
    end

  end
end