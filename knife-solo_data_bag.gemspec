# -*- encoding: utf-8 -*-
require File.expand_path('../lib/knife-solo_data_bag/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Tommy Bishop"]
  gem.email         = ["bishop.thomas@gmail.com"]
  gem.description   = %q{}
  gem.summary       = %q{A knife plugin for working with data bags and chef solo}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "knife-solo_data_bag"
  gem.require_paths = ["lib"]
  gem.version       = Knife::SoloDataBag::VERSION
  gem.add_development_dependency 'chef', '~> 0.10.10'
  gem.add_development_dependency 'rspec', '~> 2.10.0'
  gem.add_development_dependency 'fakefs', '~> 0.4.0'
end
