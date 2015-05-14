require 'ruxtran'
include Ruxtran

# This file demonstrates the use of the XSD to DSL generator for producing an XML file
# that conforms to the schema. Method definitions are generated for each element defined.
# 
# This XSD example is taken from www.w3schools.com

conform_to_schema 'shiporder.xsd'

shiporder(:orderid => '889923') {
  orderperson 'John Smith' 
  shipto {
    name 'Ola Nordmann'
    address 'Langgt 23'
    city '4000 Stavanger'
    country 'Norway'
  }
}

