load 'lib/ruby-epub.rb'


def info_epub(epub)
puts epub.title + ' by ' + epub.creator
cover = epub.cover_image
if cover && cover.size > 0
	puts "have cover"
end
end

epub = Epub.new('test.epub')
info_epub epub
epub = Epub.new('test2.epub')
info_epub epub

