# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "magic_numbers/version"

Gem::Specification.new do |s|
  s.name        = "magic_numbers"
  s.version     = MagicNumbers::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["sotakone", "heydiplo"]
  s.email       = ["heydiplo@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{}
  s.description = %q{}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
