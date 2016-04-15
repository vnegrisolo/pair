require 'spec_helper'

RSpec.describe 'pair' do

  subject(:command)   { [load_pair, git_stub, curl_stub, 'pair'].join('; ') }
  let(:load_pair) { '. pair.sh' }
  let(:git_stub) { 'git() { echo "GIT={{$@}}"; }' }
  let(:github_user_json) { File.read('spec/fixtures/github_user.json') }
  let(:curl_stub) { "curl() { echo '#{github_user_json}'; }" }

  describe 'status' do
    subject { `#{command}` }

    it 'prints the author and committer' do
      is_expected.to include('Author')
      is_expected.to include('GIT={{config --get pair.author.email}}')
      is_expected.to include('GIT={{config --get pair.author.name}}')
      is_expected.to include('Committer')
      is_expected.to include('GIT={{config --get pair.committer.email}}')
      is_expected.to include('GIT={{config --get pair.committer.name}}')
    end
  end

  describe 'confirure' do
    context 'when pair is set with just one user' do
      subject { `#{command} vnegrisolo` }

      it 'call git commit with same params' do
        is_expected.to include('GIT={{config pair.author.email vinicius.negrisolo@gmail.com}}')
        is_expected.to include('GIT={{config pair.author.name Vinicius Ferreira Negrisolo}}')
      end
    end

    context 'when pair is set with two users' do
      subject { `#{command} vnegrisolo user2` }

      it 'call git commit with same params' do
        is_expected.to include('GIT={{config pair.author.email vinicius.negrisolo@gmail.com}}')
        is_expected.to include('GIT={{config pair.author.name Vinicius Ferreira Negrisolo}}')
        is_expected.to include('GIT={{config pair.committer.email vinicius.negrisolo@gmail.com}}')
        is_expected.to include('GIT={{config pair.committer.name Vinicius Ferreira Negrisolo}}')
      end
    end
  end

  describe 'reset' do
    subject { `#{command} reset` }

    it 'resets pair config' do
      is_expected.to include('GIT={{config pair.author.email }}')
      is_expected.to include('GIT={{config pair.author.name }}')
      is_expected.to include('GIT={{config pair.committer.email }}')
      is_expected.to include('GIT={{config pair.committer.name }}')
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
