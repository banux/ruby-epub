load 'ruby-epub.rb'

epub = Epub.new('test.epub')
puts epub.title + ' by ' + epub.creator

