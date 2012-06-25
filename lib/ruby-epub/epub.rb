require 'zip/zip'
require 'nokogiri'

require 'ruby-epub/ocf'
require 'ruby-epub/opf'

module Epub

  class Epub

  attr_accessor :version, :new_file

   def initialize(filename, version = '3')
      @new_file = false
      if !File.exist? filename
        @new_file = true
      end
      @zip = Zip::ZipFile.open(filename, Zip::ZipFile::CREATE)
      @ocf = OCF.new(@zip, @new_file)
      @opf = OPF.new(@ocf.get_opf_path, @zip, @new_file)
   end


    
   def cover_image
     content, img_name = cover_by_cover_id
     if !content
       content, img_name = cover_by_meta_cover
     elsif !content
       content, img_name = cover_image_by_html
     end
 
     if content
       temp = Tempfile.new(['book_cover', File.extname(img_name)])
       temp.binmode
       temp.write(content)
       temp.flush
       if(temp.size > 0)
         return File.new(temp.path)
       else
         return nil
       end
      end
   end

   def cover_image_by_html
    cover_item = @opf.search("//package/guide/reference[@type='cover']")
    if cover_item && cover_item.first
      cover_url = cover_item.first['href']
      doc_cover = Nokogiri::HTML @zip.get_input_stream(@base_path + cover_url)
      tab_path = cover_url.split('/')
      html_path = ''
      if tab_path.size > 1
         html_path = tab_path[0] + '/'
      end
      img_src = doc_cover.xpath('//img').first
      begin
      	@image_cover = @zip.get_input_stream(@base_path + html_path + img_src['src']) {|f| f.read}
        return [@image_cover, img_src['src']]
      rescue
        return nil
      end
    end
   end

   def cover_by_meta_cover
    img_id = @opf.search("//meta[@name='cover']")
    if img_id && img_id.first
    img_item = @opf.search("//manifest/item[@id='"+ img_id.first['content'] + "']")
    if img_item && img_item.first
      img_url = @base_path + img_item.first['href']
      @image_cover = @zip.get_input_stream(img_url) {|f| f.read}
      return [@image_cover, img_item.first['href']]
    else
     return nil
    end
    end
   end

   def cover_by_cover_id
    img_item = @opf.at_xpath("//manifest/item[@id='cover']")
    if img_item 
      img_url = @base_path + img_item['href']
      @image_cover = @zip.get_input_stream(img_url) {|f| f.read}
      return [@image_cover, img_item['href']]
    else
     return nil
    end
   end

   def add_html


   end

   def add_css

   end

   def add_font

   end
  
   def save

   end



end
end