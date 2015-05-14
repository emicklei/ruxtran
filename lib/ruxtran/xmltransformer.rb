require 'rexml/document'
require 'builder'

module Ruxtran
  
  # XMLTransformer is an abstract implementation of a simple XSLT-like document element handler
  # that sends a message based on the name of the Element.
  # So when the transformer sees <mytag> then it tries to send the method handle_mytag
  # passing the DOM element.
  # 
  # @author ernest.micklei@philemonworks.com
  
  class XMLTransformer
    attr_reader :workingDirectory
    attr_reader :inputFilename
    attr_reader :outputFilename
    # Answers the output file to which the transformer is writing
    attr_reader :output
    
    # Lazy initialize the markup variable for transformers that output to XML
    # Subclasses should not use this variable directly
    def markup
      return @markup if @markup  
      @markup = Builder::XmlMarkup.new(:target => self.output, :indent => 1)
    end
    
    # subclasses may redefine this to see a trace of methods sends
    def log
      false
    end
    
    # Call this method in your class definition for tags that do not need to be transformed
    # For instance,  handle_as_is [:table, :tr, :td, :th] will install handlers that just duplicate the node structure for a table
    def XMLTransformer.handle_as_is symbolArray
      for sym in symbolArray
        source = 
"def handle_#{sym} node
	self.markup.#{sym}(node.attributes) { self.apply node }
end"
        XMLTransformer.class_eval source
      end
    end	  
    
    # Iterate over the children of the anElement and handle them successively
    # unless an abort is given. If a block is given then evaluate that after each child.
    def apply anElement
      unless anElement 
        return
      end
      anElement.each {|e| 
        unless @abort
          handle(e)
          yield if block_given?
        end }
    end
    
    # Inspect the type of the Node and dispatch accordingly  
    def handle anElement
      if anElement.kind_of? REXML::Text
        self.handleTextElement(anElement) 
      elsif anElement.kind_of? REXML::Element
        self.handleElement anElement  
      elsif anElement.kind_of? REXML::Instruction
        self.process_instruction anElement
      else
        return #ignore comments and processing instructions
      end
    end
    
    # Try dispatch to a handler method, if not then use the default handling method
    def handleElement anElement
      handler_method = self.method_from_element anElement
      if self.respond_to? handler_method
        if log 
          puts "#{self.class} - sending:#{handler_method}"
        end
        self.send(handler_method, anElement)
      else
        default_handler(anElement)  
      end
    end
    
    # Construct a method name from an Element, subclasses may override this
    # Return the name prefixed with "handle_"  and replace dashes by underscores
    def method_from_element anElement
      'handle_' + anElement.name.tr('-','_')
    end
    
    # This is a no-transform. If logging enabled then produce a log event.
    def default_handler anElement
      if log
        puts "#{self.class} - default handling:#{anElement.name}"
      end
    end  
    
    # Output the text of the element
    def handleTextElement someText
      @output << someText.value.strip if @output
    end 
    
    # Convenience method to do all the work at once
    # Usage:   MyHandler.new.transform 'input.xml' 'ouput.xml'
    def transform (xmlIn,xmlOut)
      begin
        now = Time.now
        self.basic_transform xmlIn,xmlOut
        puts "#{self.class} - [#{xmlIn}] -> [#{xmlOut}] : #{Time.now - now} ms"
      rescue
        puts "#{self.class} - ERROR: Unable to transform [#{xmlIn}] into [#{xmlOut}] because: #{$!}"
      end
    end
    
    # Method to do all the work at once
    def basic_transform (filenameIn,filenameOut)
      @inputFilename = filenameIn
      @outputFilename = filenameOut
      self.with_document_do(filenameIn) { |doc|    
        File.open(filenameOut,'w'){ |target|        
          @output = target
          self.apply doc
        }
      }
    end
    
    def with_document_do (xmlIn)
      File.open(xmlIn) { |source |
        # take working directory from input XML ; needed for processing include instructions        
        @workingDirectory = File.dirname(xmlIn)
        doc = REXML::Document.new source
        yield doc
      }
    end
    
    # Generic process instruction encountered, dispatch it
    def process_instruction anElement
      msg = 'process_' + anElement.target
      if self.respond_to? msg
        self.send(msg,anElement)
      end
    end    
    
    # Convenience method to include other XML contents that will    
    # be processed by the receiver
    def process_include anElement
      self.transform_include anElement.content
    end
    
    def transform_include include_file
      begin
        to_include = include_file
        unless include_file.include? ':'
          to_include = File.join(@workingDirectory,include_file)
        end
        if not(test(?e,to_include))
          puts "#{self.class} - ERROR, include file does not exist: #{to_include}" 
          return 
        end        
        if log 
          puts "#{self.class} - including:#{to_include}"
        end
        # remember old workingDirectory
        cwd = @workingDirectory
        self.with_document_do(to_include)
        # restore it
        @workingDirectory = cwd
      rescue
        puts "#{self.class} - ERROR: Unable to handle:#{anElement.content} in cwd: #{@workingDirectory} because: #{$!}"
      end
    end
    
  end # class
  
end # module

# test
if __FILE__== $0
  puts Ruxtran::XMLTransformer
end



