require 'ruxtran/toxdoc'

module Ruxtran

# XML transformer to generate XDoc from WSDL
# ernest.mickei@philemonworks.com, June 2006
class WSDL2XDocTransformer < ToXDocTransformer
	def handle_definitions node
		self.markup << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
		self.markup.document {
			self.markup.title node.attributes['name']
			self.markup.body {
				self.apply_all_porttypes node				
				self.apply_all_messages node
				self.apply_all_types node				
			}
		}		
	end	
	def handle_documentation node
		self.apply node if node.has_text?
	end
	def handle_message node
		self.markup.tr(:class => self.next_row_class) {
			self.markup.td {
				self.markup << node.attributes['name']
				self.markup.ul {
					self.apply node
				}
			}
		}
	end
	def handle_part node
		self.in_table_do {
			self.in_row_do {
				# self.markup.td node.attributes['name']				
				self.markup.td node.attributes['element']
			}
		}
	end
	def handle_portType node
		self.markup.section(:name => node.attributes['name']){			
			self.apply(node){
				self.markup.p
			}
		}
	end
	def handle_operation node
		self.in_table_do {
			self.in_row_do {
				self.markup.td 'Operation'
				self.markup.td node.attributes['name']
			}
			self.apply node
		}
	end
	def handle_input node
		self.in_row_do {
			self.markup.td 'Input'
			self.markup.td node.attributes['message']
		}
	end
	def handle_output node
		self.in_row_do {
			self.markup.td 'Output'
			self.markup.td node.attributes['message']
		}		
	end
	
	def apply_all_types node
	end
	def apply_all_messages node
		self.markup.section(:name => 'Messages') {
			self.in_table_do {			
				node.elements.each("//message") { |msg| self.handle msg }
			}
		}
	end

	def apply_all_porttypes node
		self.in_table_do {			
			node.elements.each("//portType") { |msg| self.handle msg }
		}
	end
	
	def log
		!true
	end
end

end # module

# this statement allows you to use this script with ruxtran
Ruxtran::WSDL2XDocTransformer.new.transform($ruxtran[0],$ruxtran[1]) if $ruxtran

# test
if __FILE__== $0
	puts Ruxtran::WSDL2XDocTransformer
end