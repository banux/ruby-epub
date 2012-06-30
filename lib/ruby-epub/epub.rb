require 'zip/zip'
require 'nokogiri'

require 'ruby-epub/ocf'
require 'ruby-epub/opf'
require 'ruby-epub/toc'

module Epub

  class Epub

  attr_accessor :version, :new_file

   def initialize(filename, version = '3')
      @new_file = false
      @version = version
      if !File.exist? filename
        @new_file = true
      end
      @zip = Zip::ZipFile.open(filename, Zip::ZipFile::CREATE)
      if @new_file
        @zip.get_output_stream('mimetype') {|f| f.write 'application/epub+zip' }
      end
      @ocf = OCF.new(@zip, @new_file)
      @opf = OPF.new(@ocf.get_opf_path, @zip, @new_file)
      @toc = TOC.new(@zip, @new_file)
   end
    

   def add_html(filepath, name)
    filename = add_file_to_zip filepath
    if filename
      @opf.add_html filename
      @toc.add filename, name
    end
   end

   def add_css
    filename = add_file_to_zip filepath
    if filename
      # add to opf
    end
   end

   def add_font
    filename = add_file_to_zip filepath
    if filename
      # add to opf
    end
   end

   def add_img(cover = false)
    filename = add_file_to_zip filepath
    if filename
      # add to opf
    end
   end

   def save
    @ocf.save
    @opf.save
    @toc.save
    @zip.commit
   end

private

  def add_file_to_zip(filepath)
    if File.exist? filepath
      @zip.get_output_stream(base_path + filepath) { |f| f.write File.open(filepath).read }
      return base_path + filepath
    else
      return nil
    end 
  end

  def base_path
    if version == 3
      return 'OPS/'
    else
      return 'OEBPS/'
    end
  end

end
end