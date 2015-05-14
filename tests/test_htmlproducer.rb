require 'ruxtran'
include Ruxtran

puts "Testing #{HTMLProducer}"

hp = HTMLProducer.new
hp.doctype_html
hp.style_css 'test_htmlproducer.css'