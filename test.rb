load 'lib/ruby-epub.rb'


def info_epub(epub)
puts epub.title + ' by ' + epub.creator
cover = epub.cover_image
if cover && File.open(cover).size > 0
	puts "have cover " + File.open(cover).path
end
end

epub = Epub.new('test/test.epub')
info_epub epub
epub = Epub.new('test/test2.epub')
info_epub epub
epub = Epub.new('test/test3.epub')
info_epub epub
STDIN.read
