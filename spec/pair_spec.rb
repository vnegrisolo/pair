require 'spec_helper'

RSpec.describe 'pair' do

  subject(:command)   { [load_pair, git_stub, 'pair'].join('; ') }
  let(:load_pair) { '. pair.sh' }
  let(:git_stub) { 'git() { echo "GIT={{$@}}"; }' }

  context 'when pair commits' do
    subject { `#{command} commit --amend` }

    it 'call git commit with same params' do
      is_expected.to include("GIT={{commit --amend}}")
    end
  end
end
