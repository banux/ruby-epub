
module Epub
	class TOC

		def initialize(zipfile, new_file, version = 3)
			@version = version
			@entry = []
			@toc = nil
			@ncx = nil
		end

		def add(filename, name, params = {})
			@entry.push ({"filename" => filename, "name" => name, "params" => params})
		end

		def save
			build
			puts @entry
			puts @toc
			puts @ncx
		end

private

	def build
		if @version == 3
			build_xhtml_toc
			build_ncx
		else
			build_ncx
		end
	end

	def build_ncx
		new_ncx = Nokogiri::XML::Builder.new do |xml|
		end
		@ncx = new_ncx.to_xml
	end

	def build_xhtml_toc
		new_toc = Nokogiri::HTML::Builder.new do |html|
		end
		@toc = new_toc.to_html
	end

	end
end