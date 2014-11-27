# -*- encoding: utf-8 -*-
require File.expand_path('../lib/prawml/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Wanderson Policarpo", "Edson Júnior"]
  gem.email         = ["wpolicarpo@gmail.com", "ejunior.batista@gmail.com"]
  gem.description   = "Prawml is a Yaml DSL interpreted by ruby over Prawn gem to generate PDF files easily"
  gem.summary       = "Yaml intends to help you generate PDF files writing only an yaml file."
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "prawml"
  gem.require_paths = ["lib"]
  gem.version       = Prawml::VERSION

  gem.add_dependency "prawn", "~> 0.13.2"
  gem.add_dependency "barby"
  gem.add_dependency "activesupport", "~> 3.0"
end

