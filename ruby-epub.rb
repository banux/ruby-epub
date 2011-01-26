require 'zip/zip'
require 'rexml/document'

class Epub
   attr_accessor :title, :language, :publisher, :date, :rights, :creator

   def initialize(filename)
      zip = Zip::ZipFile.open(filename)
      opf = get_opf(zip)
      get_metadata(opf)
   end

   def get_opf(zipfile)
      container_file = zipfile.get_input_stream("META-INF/container.xml")
      container = REXML::Document.new container_file
      opf_path = container.root.elements["rootfiles/rootfile"].attributes["full-path"]
      opf_file = zipfile.get_input_stream(opf_path)
      opf = REXML::Document.new opf_file  
   end

   def get_metadata(opf)
      @title = opf.root.elements["metadata/dc:title"].text
      @language = opf.root.elements["metadata/dc:language"].text
      @publisher = opf.root.elements["metadata/dc:publisher"].text
#      @date = opf.root.elements["metadata/dc:date"].text
#      @rights = opf.root.elements["metadata/dc:rights"].text
      @creator = opf.root.elements["metadata/dc:creator"].text
   end

end

epub = Epub.new('test.epub')
puts epub.title + ' by ' + epub.creator
