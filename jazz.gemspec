# -*- encoding: utf-8 -*-
require File.expand_path('../lib/jazz/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Mark Anthony Gibbins"]
  gem.email         = ["xiy3x0@gmail.com"]
  gem.description   = %q{TODO: Jazz is a documentation generator for Ruby that turns your code
                        documentation into something compelling, and rich.}
  gem.summary       = %q{TODO: The smooth way to generate documentation.}
  gem.homepage      = "http://github.com/xiy/jazz"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "jazz"
  gem.require_paths = ["lib"]
  gem.version       = Jazz::VERSION

  gem.add_dependency('slim')
  gem.add_dependency('redcarpet', '~> 1.17')
  gem.add_dependency('rgl')
  gem.add_dependency('ruby_parser')
  gem.add_dependency('colorize')
  gem.add_dependency('parallel')

  gem.add_development_dependency('rspec')
  gem.add_development_dependency('spork')
  gem.add_development_dependency('guard')
  gem.add_development_dependency('guard-bundler')
  gem.add_development_dependency('guard-spork')
  gem.add_development_dependency('guard-rspec')
  gem.add_development_dependency('foreman')
end
