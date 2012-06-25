
module Epub

class OPF

	def initialize(opf_path, zipfile, new_file)
    @items = {}
    @spine = {}
    @metadata = {}
    @zip = zipfile
    if !new_file
      opf_file = @zip.get_input_stream(opf_path)
      @opf = Nokogiri::XML opf_file
    else
      new_opf = Nokogiri::XML::Builder.new do |xml|
        xml.package('xmlns' => 'http://www.idpf.org/2007/opf', 'version' => '3.0') {
          xml.metadata('xmlns:dc' => "http://purl.org/dc/elements/1.1/", )
          xml.manifest
          xml.spine
        }
        end
        @zip.get_output_stream(opf_path) { |f| f.write new_opf.to_xml }
        @zip.commit
        @opf = Nokogiri::parse new_opf.to_xml
      end

		  tab_path = opf_path.split('/')
      @base_path = ''
      if tab_path.size > 1 
         @base_path = tab_path[0] + '/'
      end
      if !new_file
        get_metadata
      end
    end

    def get_metadata()      
    @opf.at_xpath("//metadata").children.each do |elem|
      #puts elem.inspect
      if elem.name != 'text'
        if elem.name == "meta"
          name_elem = elem['name']
          content_elem = elem['content']
        else
          name_elem = elem.name
          content_elem = elem.content
        end
        @metadata[name_elem] = content_elem
      end
    end
   end


 end
end