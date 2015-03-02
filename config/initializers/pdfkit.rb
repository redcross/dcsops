# config/initializers/pdfkit.rb
PDFKit.configure do |config|
  margin = '.25in'
  config.default_options = {
    :page_size => 'Letter',
    :print_media_type => true,
    margin_bottom: margin, margin_top: margin, margin_left: margin, margin_right: margin
  }
end
