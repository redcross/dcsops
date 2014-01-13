module PdfResponder
  include ActsAsFlyingSaucer::Controller
  acts_as_flying_saucer

  delegate :send_file, to: :controller

  def initialize(controller, resources, options={})
    super
    @filename = options.delete :filename
    @disposition = options.delete(:disposition) || 'inline'
  end

  def to_pdf
    opts = {send_file: {type: :pdf, filename: @filename, disposition: @disposition}}
    render_pdf opts
  end

  def render_to_string *args
    # Need to manually specify html format, as be default it will be looking for pdf.
    opts = args.first.merge(options).merge({formats: [:html], action: default_action})
    controller.render_to_string opts
  end
end
