require 'ruxtran/xmltransformer'

module Ruxtran

# ToXDocTransformer is an abstract class that provides
# convenience methods for writing XDoc tables with the 
# correct CSS classes used by the Apache Maven tool.
# 
# E.M.Micklei, July 2006
class ToXDocTransformer < XMLTransformer
	def in_table_do
		@rowclass = 'b'
		self.markup.table(:class => 'bodyTable') { yield }
	end
	
	def in_row_do
		self.markup.tr(:class => self.next_row_class) { yield }
	end
	
	def next_row_class
		@rowclass == 'a' ? @rowclass = 'b' : @rowclass = 'a'
	end
end

end # module

# test
if __FILE__== $0
	puts Ruxtran::ToXDocTransformer
end