Dir['*.rb'].each { |f| require_relative "../#{f}" }

def fixture(json)
  File.read("spec/fixtures/#{json}.json")
end

require 'rspec/shell'

RSpec.configure do |c|
  c.include Rspec::Shell, type: :shell
end
