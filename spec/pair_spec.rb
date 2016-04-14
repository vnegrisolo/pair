require 'spec_helper'

RSpec.describe 'pair' do

  let(:git_stub)  { 'git() { echo "GIT={{$@}}"; }' }
  let(:load_pair) { '. pair.sh' }
  let(:command)   { [load_pair, git_stub, 'pair'].join('; ') }

  it 'prints pair status' do
    expect(`#{command}`).to eq("pair running\nGIT={{--version}}\n")
  end
end
