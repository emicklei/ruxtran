require 'ruxtran'
include Ruxtran

puts "Testing #{XMLTransformer}"

XMLTransformer.new.transform('example1.xml', 'output_test_xmltransformer.xml')