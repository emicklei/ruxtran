require 'ruxtran/toxdoc'

module Ruxtran

# XML transformer to generate XDoc from XSD
# E.M.Micklei, May 2006
class XSD2XDocTransformer < ToXDocTransformer
	def log
		!true
	end
	
	def handle_document node
		self.markup << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
		self.apply node
	end
	
	def handle_import node
		#ignore
	end
		
	def handle_schema node
		#targetNamespace,elementFormDefault,xmlns:*
		self.markup << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
		self.markup.document {
			self.markup.title(node.attributes['targetNamespace'])
			self.markup.body {
			     self.markup.section(:name => @inputFilename){
			         self.apply node}}
		}
	end
	
	def handle_element node
		# either a reference, a simple definition or a complex one
		type = node.attributes['type']
		if !type.nil?
			# as reference?
			name = node.attributes['name']
			return if name == type
			# simple definition
			self.in_row_do {
				self.markup << "<td>#{name}</td><td>#{self.without_ns(type)}</td><td>#{node.attributes['user']}</td>"
			}
			return
		end
		# as definition
		self.markup.subsection('name'=> node.attributes['name']){
			self.in_table_do {
				self.in_row_do {
					self.markup << "<th>Attribute</th><th>Type</th><th>Use</th>"
				}
				sorted = node.elements.sort { |e1,e2| (e1.attributes['name']||'') <=> (e2.attributes['name']||'') }
				sorted.each { |kid| self.handle kid }				
			}		
		}
	end
	
	def handle_complexType node
		if node.attributes['name'].nil?
			self.apply node
		else
			self.handle_element node
		end
	end
	
	def handle_complexContent node
		self.apply node
	end
	
	def handle_extension node		
	end
	
	def handle_sequence node
		sorted = node.elements.sort { |e1,e2| (e1.attributes['name']||'') <=> (e2.attributes['name'] ||'')}
		sorted.each { |kid| self.handle kid }
	end
	
	def handle_simpleType node
		self.apply node
	end
	
	def handle_attribute node
		#name,type,use
		self.in_row_do {
			self.markup.td(node.attributes['name'])
			type = node.attributes['type']
			if type
				self.markup.td(self.without_ns(type))
			else # process simple type
				self.apply node
			end
			self.markup.td(node.attributes['use'] || '?')
		}
	end
	
	def handle_restriction node
		self.markup.td(self.without_ns(node.attributes['base']))
	end
	
	def handle_maxLength node
	end
	
	# if the tag is prefixed with a namespace then return it without
	def without_ns tag
		tag[(tag.index(':') || -1) +1..tag.size]
	end
	
end # class

end # module

# this statement allows you to use this script with ruxtran
Ruxtran::XSD2XDocTransformer.new.transform($ruxtran[0],$ruxtran[1]) if $ruxtran

# test
if __FILE__== $0
	puts Ruxtran::XSD2XDocTransformer
end