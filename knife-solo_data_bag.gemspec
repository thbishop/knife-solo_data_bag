# -*- encoding: utf-8 -*-
require File.expand_path('../lib/knife-solo_data_bag/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Tommy Bishop"]
  gem.email         = ["bishop.thomas@gmail.com"]
  gem.description   = %q{A knife plugin for working with data bags and chef solo}
  gem.summary       = %q{A knife plugin for working with data bags and chef solo}
  gem.homepage      = 'https://github.com/thbishop/knife-solo_data_bag'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "knife-solo_data_bag"
  gem.require_paths = ["lib"]
  gem.version       = Knife::SoloDataBag::VERSION
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '>= 3.0'
  gem.add_development_dependency 'fakefs'
end
