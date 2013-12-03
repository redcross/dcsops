class CreditCardInput <  FormtasticBootstrap::Inputs::StringInput
  def initialize(*opts)
    opts.last[:prepend] = "<i class='icon-credit-card'></i>".html_safe
    #opts.last[:append] = "<button class='btn datepicker-today'>Today</button>".html_safe
    super *opts
  end

  def to_html
    id = input_html_options[:id]

    super << <<-HTML.html_safe
    <script>
      $("##{id}").validateCreditCard(function(result) {
        var $el = $('##{id}')
        var valid = (result.length_valid && result.luhn_valid);
        var emptyOk = $el.val().length === 0 && !$el.closest('.control-group').hasClass('required');
        $el.closest('.control-group').toggleClass('error', !(valid || emptyOk));
        if (valid) {
          var str = $el.val().replace(/[^0-9]/g, '');
          str = [str.substr(0, 4), str.substr(4, 4), str.substr(8, 4), str.substr(12)].join("-")
          $el.val(str)
        }
      });
    </script>
    HTML
    
  end
end