require 'ruxtran/htmlproducer'

module Ruxtran

class XDoc2HTMLTransformer < HTMLProducer 
    # these nodes are output as is (no transformation)
    handle_as_is [:table,:tr,:td,:th]

    # AUTHOR
    def handle_author anElement
    end

    # BODY
    def handle_body anElement
        self.apply anElement
    end

    # DOCUMENT
    def handle_document anElement    
        self.doctype_html
        markup.html { 
            self.style_css 'xdoc.css'
            markup.body { 
                self.apply anElement }}
    end        
    
    # EXAMPLE
    def handle_example anElement
        markup.p
        markup.table(:class => 'example' ) {
            markup.tr {
                markup.td {
                    self.apply anElement }}}
    end    
    
    # ESCAPEXML
    def handle_escapeXml anElement
        self.apply anElement
    end
    
    # NAVBAR
    # <navbar prev="first.html" home="../index.html" next="next.html"/>
    def handle_navbar anElement
        self.apply anElement
    end

    # PROPERTIES
    def handle_properties anElement         
        self.apply anElement
    end

    # SECTION
    def handle_section anElement
        markup.h2(anElement.attributes["name"])    
        self.apply anElement
    end
    
    # SUBSECTION
    def handle_subsection anElement
        markup.h3(anElement.attributes["name"])           
        self.apply anElement
    end

    # RELEASE
    def handle_release anElement
        markup.h3(anElement.attributes["version"])           
        self.apply anElement
    end     
    
    # SOURCE
    def handle_source anElement
        markup.div(:class => 'source') {
            markup.pre {
                anElement.each_child do |e| markup << e.to_s end
            }
        }
    end
    
    # TITLE
    def handle_title anElement
    end
    
end # class

end # module

# this statement allows you to use this script with ruxtran
#Ruxtran::XDoc2HTMLTransformer.new.transform($ruxtran[0],$ruxtran[1]) if $ruxtran
Ruxtran::XDoc2HTMLTransformer.new.transform(ARGV[0],ARGV[2]) if ARGV.size > 0