# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'magic_numbers/version'

Gem::Specification.new do |s|
  s.name        = 'magic_numbers'
  s.version     = MagicNumbers::VERSION
  s.authors     = [ 'sotakone', 'heydiplo' ]
  s.email       = [ 'heydiplo@gmail.com' ]
  s.homepage    = 'https://github.com/dimko/magic_numbers'
  s.summary     = %q{}
  s.description = %q{}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = [ 'lib' ]

  s.add_dependency 'active_record', '~> 3.0'
  s.add_dependency 'active_support', '~> 3.0'
end
