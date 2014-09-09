module GridHelper
  def default_form_options
    {label: false, label_html: {}, input_html: {id: "", class: "input-sm form-control"}}
  end

  def form_options(col)
    options = default_form_options
    options.deep_merge! col.form_options if col.form_options
    evaluate_procs(options)
  end

  def evaluate_procs(opts)
    opts.merge(opts) {|k, v, _| v.respond_to?(:call) ? self.instance_exec(&v) : v }
  end
end