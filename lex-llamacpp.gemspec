# frozen_string_literal: true

require_relative 'lib/legion/extensions/llamacpp/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-llamacpp'
  spec.version       = Legion::Extensions::Llamacpp::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX llama.cpp'
  spec.description   = 'Connects LegionIO to llama.cpp inference server'
  spec.homepage      = 'https://github.com/LegionIO/lex-llamacpp'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/LegionIO/lex-llamacpp'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-llamacpp'
  spec.metadata['changelog_uri'] = 'https://github.com/LegionIO/lex-llamacpp/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/LegionIO/lex-llamacpp/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '>= 2.0'
end
