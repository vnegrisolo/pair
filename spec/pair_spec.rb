require 'spec_helper'

RSpec.describe 'pair' do

  it 'prints pair status' do
    expect(`. pair.sh; pair`).to eq("pair running\n")
  end
end
