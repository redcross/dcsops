module PartialResponder
  def to_html
    if partial = partial_name
      options.merge!(partial: partial)
    end
    super
  end

  protected

  def partial_name
    param = controller.params[:partial]
    if param and controller.valid_partial?(param)
      param
    else
      nil
    end
  end
end