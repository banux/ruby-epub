require 'zip/zip'
require 'nokogiri'

class Epub

  BANNED_META = ['office', 'amanuensis', 'calibre:user_metadata']

   def initialize(filename)
      @zip = Zip::ZipFile.open(filename)
      opf = get_opf(@zip)
      get_metadata()
   end

  def my_metadata(name) 
      # getter
      define_singleton_method("#{name}=") do |val|
        instance_variable_set("@#{name}", val)  
      end 
      # setter
      define_singleton_method("#{name}") do
        instance_variable_get("@#{name}")
      end 
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

   def banned?(meta)    
    BANNED_META.each do |ban|
      if meta[0, ban.size] == ban
        return true
      end
    end
    return false
   end

   def get_metadata()      
    @opf.at_xpath("//metadata").children.each do |elem|
      #puts elem.inspect
      if elem.name != 'text'
        if elem.name == "meta" && !banned?(elem['name'])
          name_elem = elem['name'].tr(' ', '_').tr(':', '_').tr('.', '_')
          content_elem = elem['content']
        else
          name_elem = elem.name
          content_elem = elem.content
        end
        my_metadata name_elem
        send(name_elem + '=', content_elem)
      end
    end
   end
 
   def cover_image
     content, img_name = cover_by_meta_cover
     if !content
#       content, img_name = cover_by_cover_id
#     elsif !content
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
    puts "enter by html"
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
    puts "enter meta cover"
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
    puts "by id"
    img_item = @opf.at_xpath("//manifest/item[@id='cover']")
    if img_item 
      img_url = @base_path + img_item['href']
      @image_cover = @zip.get_input_stream(img_url) {|f| f.read}
      return [@image_cover, img_item['href']]
    else
     return nil
    end
   end


end
