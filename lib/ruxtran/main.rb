# @author E.M.Micklei, 2006

def expand_to_pwd filename
	if filename.nil? 
		return nil
	end
	if File.dirname(filename) =~ /\./
		return File.join(Dir.pwd,filename)
	else
		return filename
	end
end

# process program arguments first
if ARGV.size < 3
    explain = <<EOEX
    
Ruxtran is an XML processor that requires a Ruby script for the transformation.
A transformation is written by subclassing one of the framework classes such
as XMLTransformer or, for HTML output, the HTMLProducer.
    
Usage:
	ruxtran [input] [transformation] [output]
    	
Examples:
	ruxtran book.xml xdoc.rb xbook.xdoc
	ruxtran customer.xsd xsd2xdoc.rb customer.xml
   	
Further information:
	http://www.philemonworks.com/ruxtran
	see the samples directory of this gem
EOEX
	puts explain
	exit
end

input_xml = expand_to_pwd ARGV[0]
transform_rb = expand_to_pwd ARGV[1]
output_xml = expand_to_pwd ARGV[2]

if not(test(?e,input_xml))
	puts "Sorry, input file does not exist: #{input_xml}" 
	exit
end

if test(?e,output_xml) && !test(?w,output_xml)
	puts "Sorry, output file is read-only: #{output_xml}" 
	exit
end

if not(test(?e,transform_rb))
    #try requiring it
    begin
        $ruxtran = [input_xml,output_xml]
        require 'ruxtran/'+ARGV[1].sub('.rb','')
        exit
    rescue LoadError
        puts "Sorry, transformation script does not exist and cannot be required: #{transform_rb}" 
	    exit
	end
end

# Try to determine what class is being defined by a script stored in a filename
# Return the name of the class or an empty string is none was detected
def defined_classname filename
    script = File.new filename
    script.each_line do |line|
         if line =~ /class(.*)[<|\z]/  
            script.close
            return $1.strip
         end
    end       
    script.close 
    ""
end

# detect class definition
transformer_class = defined_classname transform_rb

# abort if none was found
if transformer_class.size == 0
	puts "Sorry, no transformer class definition found in: #{transform_rb}" 
	exit
end

# load the transformation class
load transform_rb

# do the transformation
eval(transformer_class).new.transform(input_xml,output_xml)

