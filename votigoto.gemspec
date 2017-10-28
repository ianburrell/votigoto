Gem::Specification.new do |s|
  s.name        = 'votigoto'
  s.version     = '0.2.2'
  s.licenses    = ['MIT']
  s.summary     = "Ruby API wrapper for the TiVoToGo protocol."
  s.description = "Use it to access a list of recorded shows and programs on your Tivo."
  s.authors     = ["Ruby Coder"]
  s.email       = 'ianburrtell@gmail.com'
  s.files       = Dir['bin/*', 'lib/**/*', 'README.txt', 'License.txt']
  s.homepage    = 'https://rubygems.org/gems/votigoto'
  s.add_runtime_dependency 'hpricot', '>= 0.5.145'
end
