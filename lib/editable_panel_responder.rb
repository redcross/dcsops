module EditablePanelResponder
  def to_js
    if get? # new,edit
      render
    elsif has_errors? # create or update and failed
      render action: :edit
    else # successfull create, update, or destroy
      render action: :update
    end
  end
end