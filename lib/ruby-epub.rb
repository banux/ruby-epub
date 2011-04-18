require 'zip/zip'
require 'nokogiri'

class Epub
   attr_accessor :title, :language, :publisher, :date, :rights, :creator

   def initialize(filename)
      @zip = Zip::ZipFile.open(filename)
      opf = get_opf(@zip)
      get_metadata()
   end

   def get_opf(zipfile)
      container_file = zipfile.get_input_stream("META-INF/container.xml")
      container = Nokogiri::XML container_file
      opf_path = container.at_css("rootfiles rootfile")['full-path']
      tab_path = opf_path.split('/')
      @base_path = ''
      if tab_path.size > 1 
         @base_path = tab_path[0] + '/'
      end
      opf_file = zipfile.get_input_stream(opf_path)
      @opf = Nokogiri::XML opf_file 
      @opf.remove_namespaces! 
   end

   def get_metadata()
    if @opf.at_css("title")
      @title = @opf.at_css("title").content
    end
    if @opf.at_css("language")
      @language = @opf.at_css("language").content
    end
    if @opf.at_css("publisher")
      @publisher = @opf.at_css("publisher").content
    end
    if @opf.at_css("date")
      @date = @opf.at_css("date").content
    end
    if @opf.at_css("rights")
      @rights = @opf.at_css("rights").content
    end
    if @opf.at_css("creator")
      @creator = @opf.at_css("creator").content
    end
   end
 
   def cover_image
     content = cover_by_cover_id
     return content if content
     content = cover_by_meta_cover
     return content if content
     content = cover_image_by_html
     return content if content 
   end

   def cover_image_by_html
    cover_item = @opf.at_css("package guide reference[@type='cover']")
    if cover_item
      cover_url = cover_item['href']
      doc_cover = Nokogiri::HTML @zip.get_input_stream(@base_path + cover_url)
      tab_path = cover_url.split('/')
      html_path = ''
      if tab_path.size > 1
         html_path = tab_path[0] + '/'
      end
      img_src = doc_cover.xpath('//img').first
      begin
      	@image_cover = @zip.get_input_stream(@base_path + html_path + img_src['src']) {|f| f.read}
        return @image_cover
      rescue
        return nil
      end
    end
   end

   def cover_by_meta_cover
    img_id = @opf.at_css("meta[@name='cover']")
    if img_id
    img_item = @opf.at_css("manifest item[id='"+ img_id['content'] + "']")
    if img_item
      img_url = @base_path + img_item['href']
      @image_cover = @zip.get_input_stream(img_url) {|f| f.read}
      return @image_cover
    else
     return nil
    end
    end
   end

   def cover_by_cover_id
    img_item = @opf.at_css("manifest item #cover")
    if img_item
      img_url = img_item['href']
      puts img_url
      @image_cover = @zip.get_input_stream(img_url) {|f| f.read}
      return @image_cover
    else
     return nil
    end
   end


end
