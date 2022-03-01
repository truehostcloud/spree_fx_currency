# encoding: UTF-8

lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_fx_currency/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_fx_currency'
  s.version     = SpreeFxCurrency.version
  s.summary     = 'Spree currency converter'
  s.description = 'Use foreign exchange rates (relative to main currency) '\
                  'mannualy entered in admin area'
  s.required_ruby_version = '>= 2.1.0'

  s.author    = 'Artem Russkikh'
  s.email     = 'rusartx@gmail.com'
  # s.homepage  = 'http://www.spreecommerce.com'
  s.license = 'BSD-3'

  # s.files       = `git ls-files`.split("\n")
  # s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  spree_version = '>= 4.4.0'
  s.add_dependency 'spree', spree_version
  s.add_dependency 'spree_backend', spree_version
end
