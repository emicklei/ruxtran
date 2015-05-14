require 'ruxtran/xmltransformer'

module Ruxtran

class HTMLProducer < XMLTransformer
    attr_reader :css
    attr_reader :links

    def initialize
        @links = {}
        @css = []
        super
    end
    
    # Convenience method for inserting a CSS reference into a HTML document
    # <style type="text/css" media="all">@import "your.css";</style>
    def style_css url
        @css << url unless @css.include? url
        self.markup.style(:type => 'text/css', :media => 'all'){
            self.markup.text! "@import \"#{url}\";"
        }
    end    

    # Convenience method for inserting a DOCTYPE reference into a HTML document
    def doctype_html
        self.markup << <<END_DOCTYPE
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
END_DOCTYPE
    end  
        
    # Convenience method to inserting hyperlinks. Two cases:
    # 1 : if the href attribute is specified than add the link definition
    # 2 : else replace a reference to a link with a proper HTML anchor
    def handle_link anElement
        href = anElement.attributes["href"]
        if (href != nil)
            @links[anElement.attributes["name"]] = href
        else
            self.markups.a(:href => @links[anElement.attributes["name"]]) { markup << anElement.attributes["name"] }
        end
    end
    
    # HTML allows for the inclusion of arbitrary HTML code 
    #
    def handle_html anElement
        anElement.children.each { |e| markup << e.to_s}
    end
    
    # LINKS allows for the specification of a list of links. No output is generated.
    #    
    def handle_links anElement
        self.apply anElement
    end    
    
end # class

end # module


# test
if __FILE__== $0
	puts Ruxtran::HTMLProducer
end