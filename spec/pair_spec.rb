require 'spec_helper'

RSpec.describe 'pair' do

  subject(:command)   { [load_pair, git_stub, curl_stub, 'pair'].join('; ') }
  let(:load_pair) { '. pair.sh' }
  let(:git_stub) { 'git() { echo "GIT={{$@}}"; }' }
  let(:github_user_json) { File.read('spec/fixtures/github_user.json') }
  let(:curl_stub) { "curl() { echo 'CURL={{$@}}'; echo '#{github_user_json}'; }" }

  describe 'confirure' do
    context 'when pair is set with just one user' do
      subject { `#{command} vnegrisolo` }

      it 'call git commit with same params' do
        is_expected.to include('GIT={{config pair.author.email vinicius.negrisolo@gmail.com}}')
        is_expected.to include('GIT={{config pair.author.name Vinicius Ferreira Negrisolo}}')
      end
    end
  end

  describe 'proxy commits' do
    context 'when pair commits' do
      subject { `#{command} commit --amend` }

      it 'call git commit with same params' do
        is_expected.to include('GIT={{commit --amend}}')
      end
    end
  end

end
