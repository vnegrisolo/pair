Dir['*.rb'].each { |f| require_relative "../#{f}" }
Dir['spec/support/*.rb'].each { |f| require_relative "../#{f}" }

def fixture(json)
  File.read("spec/fixtures/#{json}.json")
end
