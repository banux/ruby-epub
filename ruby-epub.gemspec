Gem::Specification.new do |spec|

  spec.authors = ["banux"]
  spec.description = %q{Extract epub metada}
  spec.summary = %q{Extract epub metada}
  spec.email = %q{banux@helheim.net}
  spec.name = 'ruby-epub'
  spec.version = '0.2.8'
  spec.files = ['README', 'lib/ruby-epub.rb']
  spec.add_dependency('rubyzip2')
  spec.add_dependency('nokogiri')
end  
