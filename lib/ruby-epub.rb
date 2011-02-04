require 'zip/zip'
require 'rexml/document'

class Epub
   attr_accessor :title, :language, :publisher, :date, :rights, :creator

   def initialize(filename)
      @zip = Zip::ZipFile.open(filename)
      opf = get_opf(@zip)
      get_metadata()
   end

   def get_opf(zipfile)
      container_file = zipfile.get_input_stream("META-INF/container.xml")
      container = REXML::Document.new container_file
      opf_path = container.root.elements["rootfiles/rootfile"].attributes["full-path"]
      opf_file = zipfile.get_input_stream(opf_path)
      @opf = REXML::Document.new opf_file  
   end

   def get_metadata()
    if @opf.root.elements["metadata/dc:title"]
      @title = @opf.root .elements["metadata/dc:title"].text
    end
    if @opf.root.elements["metadata/dc:language"]
      @language = @opf.root.elements["metadata/dc:language"].text
    end
    if @opf.root.elements["metadata/dc:publisher"]
      @publisher = @opf.root.elements["metadata/dc:publisher"].text
    end
    if @opf.root.elements["metadata/dc:date"]
      @date = @opf.root.elements["metadata/dc:date"].text
    end
    if @opf.root.elements["metadata/dc:rights"]
      @rights = @opf.root.elements["metadata/dc:rights"].text
    end
    if @opf.root.elements["metadata/dc:creator"]
      @creator = @opf.root.elements["metadata/dc:creator"].text
    end
   end
 
   def cover_image
    img_item = @opf.root.elements["manifest/item[@id='cover-image']"]
    if img_item
      img_url = 'OEBPS/' + img_item.attributes['href']
puts img_url
      @image_cover = @zip.get_input_stream(img_url) {|f| f.read}
      return @image_cover
    end
   end

end
