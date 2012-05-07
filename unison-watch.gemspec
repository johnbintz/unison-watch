Gem::Specification.new do |gem|
  gem.authors       = ["John Bintz"]
  gem.email         = ["john@coswellproductions.com"]
  gem.description   = %q{No-nonsense JavaScript testing solution.}
  gem.summary       = %q{No-nonsense JavaScript testing solution.}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "unison-watch"
  gem.require_paths = ["lib"]
  gem.version       = '0.0.1'

  gem.add_dependency 'qtbindings'
  gem.add_dependency 'thor'
  gem.add_dependency 'atomic'
end

