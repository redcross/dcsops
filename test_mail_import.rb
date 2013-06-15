require 'rubygems'
require 'json'
require 'base64'
require 'net/http'

f = File.open "/Users/jlaxson/Downloads/inet_38899265667380.xls"

data = Base64.encode64 f.read

#jsondata = [{
#  'event' => 'inbound',
#  'msg' => {
#    'subject' => '05503',
#    'attachments' => {
#      'test.xls' => {
#        'content' => data
#      }
#    }
#  }
#}]

jsondata = [{
  'event' => 'inbound',
  'msg' => {
    'subject' => '05503',
    'text' => File.read( "spec/fixtures/incidents/dispatch_logs/1.txt")
  }
}]

http = Net::HTTP.new "localhost", 3000
http.set_debug_output $stderr
req = Net::HTTP::Post.new '/import/test/mandrill/dispatch-v1'
req.set_form_data 'mandrill_events' => JSON.generate(jsondata)
resp = http.request req
puts resp.body

