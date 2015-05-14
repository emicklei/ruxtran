require 'ruxtran/xmltransformer'

module Ruxtran

$available = []
class XSD2DSLTransformer < XMLTransformer
	def log
		true
	end
    
        def default_handler anElement
		#traverse unknown elements
		self.apply anElement
	end
    
	def handle_element node
		source = "def #{node.attributes['name']}(*args)
	if block_given?
		$xmlmarkup.method_missing(\"#{node.attributes['name']}\",*args){ yield }		
	else
		$xmlmarkup.method_missing(\"#{node.attributes['name']}\",*args)
	end
end"
		puts source
		Ruxtran.class_eval source
		$available << node.attributes['name']
		#define methods for each attribute
		#traverse the rest
		self.apply node
	end    	
end # class

def conform_to_schema xsd
    puts "DSL generation from " + xsd
	dsl = XSD2DSLTransformer.new
	dsl.with_document_do(xsd){ |doc| dsl.apply doc }
	target = File.new(xsd.sub('.xsd','.xml'),'w')
	$xmlmarkup = Builder::XmlMarkup.new(:target => target, :indent => 1)
	$xmlmarkup << '<?xml version="1.0" encoding="UTF-8"?>' << "\n"
end

def method_missing(methodName,*args,&block)
	puts "Unknown element/attribute: #{methodName} at: #{caller[0]}"
	puts "The following elements are available:#{$available}"
end

end # module