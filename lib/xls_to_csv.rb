require 'open3'

class XlsToCsv

  def self.install!
    return unless Rails.env.production?
    return if File.exist? File.join(Rails.root, 'bin', 'xls2csv')

    system("curl -Lo /tmp/catdoc.tar.gz https://www.dropbox.com/s/o6eo9wh67vidrz0/catdoc.tar.gz")
    system("cd /; tar -zxvf /tmp/catdoc.tar.gz")
  end

  def self.executable_name
    Rails.env.production? ? File.join(Rails.root, 'bin', 'xls2csv') : 'xls2csv'
  end

  def self.convert(xls_body)
    install!

    f = Tempfile.new(["convert", '.xls'], Dir.tmpdir)
    f.binmode
    f.write xls_body.force_encoding("UTF-8")
    f.close

    csv = nil
    csv, stderr_str, status = Open3.capture3({}, executable_name, f.path)
    raise "Error in xls->csv conversion" unless status.success?

    return csv
  ensure
    if f
      f.close
      f.unlink
    end
  end

end