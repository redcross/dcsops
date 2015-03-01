class RenderMan
  cattr_accessor(:default_host_options) do
    { "HTTP_HOST"   => (ENV['WWW_HOSTNAME'] || 'localhost:3000'),
      "SCRIPT_NAME" => '',
      "HTTPS"       => Rails.env.development? ? "off" : "on",
      "rack.input"  => '' }
  end

  def self.render(*args)
    new(*args).render
  end

  def initialize(host_options: Hash.new, **rendering_options)
    @host_options, @rendering_options = host_options, rendering_options
  end

  def render
    with_script_name { controller.render_to_string @rendering_options }
  end

  def controller
    ApplicationController.new.tap do |controller|
      controller.request  = ActionDispatch::Request.new default_host_options.merge(@host_options)
      controller.response = ActionDispatch::Response.new

      controller.params = {}
      Array(@rendering_options[:assigns]).each { |k, v| controller.instance_variable_set "@#{k}", v }
      Array(@rendering_options[:defs]).each { |k, v| controller.class.send(:define_method, k) { |*args| v }; controller.class.send :helper_method, k}
    end
  end

  private
    def with_script_name
      if @host_options["SCRIPT_NAME"]
        begin
          original_default_url_options = Rails.application.routes.default_url_options
          Rails.application.routes.default_url_options = { script_name: @host_options["SCRIPT_NAME"] }
          yield
        ensure
          Rails.application.routes.default_url_options = original_default_url_options
        end
      else
        yield
      end
    end
end
