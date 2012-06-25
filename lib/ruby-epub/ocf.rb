require 'ruby-epub/epub'
require 'zip/zip'
require 'nokogiri'

module Epub

class OCF

	DEFAULT_OPF_PATH = 'OPS/package.opf'
    CONTAINER_PATH = 'META-INF/container.xml'

	def initialize(zipfile, new_file)
		@zip = zipfile
	 if !new_file
        container_file = @zip.get_input_stream(CONTAINER_PATH)
        @container = Nokogiri::XML container_file
     else
     	new_container = Nokogiri::XML::Builder.new do |xml|
     		xml.container('xmlns' => 'urn:oasis:names:tc:opendocument:xmlns:container', 'version' => '1.0') {
     			xml.rootfiles {
     				xml.rootfile('full-path' => DEFAULT_OPF_PATH, 'media-type' => 'application/oebps-package+xml')
     			}
     		}
        end
        @zip.get_output_stream(CONTAINER_PATH) { |f| f.write new_container.to_xml }
        @zip.commit
        @container = Nokogiri::parse new_container.to_xml
     end

	end

	def get_opf_path
		item = @container.at_css("rootfiles rootfile")
		if item.nil?
			opf_path = DEFAULT_OPF_PATH
		else
			opf_path = item['full-path']
		end
		return opf_path
    end

end

end
