module Incidents::EditPanelHelper
  #.modal.fade#edit-modal
  #  .modal-header 
  #    %a.close(data-dismiss="modal") &times;
  #    %h3 Edit
  #  .modal-body
  #  .modal-footer
  #    %a.btn.btn-primary(data-dismiss="modal") Close

  def edit_panel_link_to title, url, opts={}, &block
    if block_given?
      opts = url
      url = title
      title = capture(&block)
    end

    classes = opts[:class]
    classes = [classes, "edit-panel"].compact.join " "
    opts[:class] = classes

    link_to title, url, opts
  end


  def edit_panel_html(id="edit-modal", title="Edit", &block)
    content_tag(:div, id: id, class: "modal fade") do
      content_tag(:div, class: "modal-header") do
        content_tag :a, "&times;".html_safe, class: "close", data: {dismiss: "modal"}
        content_tag :h3, title
      end <<
      content_tag(:div, class: "modal-body", &block)
      content_tag(:div, class: "modal-footer") do
        content_tag :a, "Close", class: "btn btn-primary", data: {dismiss: "modal"}
      end
    end
  end
end
