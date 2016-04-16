require 'spec_helper'

RSpec.describe 'pair.sh', type: :shell do

  def pair(params = '')
    command = ['. pair.sh', git_stub, curl_stub, 'pair'].join('; ')
    `#{command} #{params}`
  end

  let(:git_stub) { 'git() { echo "GIT={{$@}}"; }' }
  let(:github_user_response) { fixture(:github_user) }
  let(:curl_stub) { "curl() { echo '#{github_user_response}'; }" }

  describe 'status' do
    subject { pair }

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

    context 'when the user does not have email or name' do
      subject { pair 'vnegrisolo' }

      let(:github_user_response) { fixture(:github_user_without_email_and_name) }

      it 'call git commit with same params' do
        is_expected.to include('ERROR => You need to set Name and Email for vnegrisolo on Github')
      end
    end

    context 'when pair is set with just one user' do
      subject { pair 'vnegrisolo' }

      it 'call git commit with same params' do
        is_expected.to include('GIT={{config pair.author.email vinicius.negrisolo@gmail.com}}')
        is_expected.to include('GIT={{config pair.author.name Vinicius Ferreira Negrisolo}}')
      end
    end

    context 'when pair is set with two users' do
      subject { pair 'vnegrisolo user2' }

      it 'call git commit with same params' do
        is_expected.to include('GIT={{config pair.author.email vinicius.negrisolo@gmail.com}}')
        is_expected.to include('GIT={{config pair.author.name Vinicius Ferreira Negrisolo}}')
        is_expected.to include('GIT={{config pair.committer.email vinicius.negrisolo@gmail.com}}')
        is_expected.to include('GIT={{config pair.committer.name Vinicius Ferreira Negrisolo}}')
      end
    end
  end

  describe 'reset' do
    subject { pair 'reset' }

    it 'resets pair config' do
      is_expected.to include('GIT={{config pair.author.email }}')
      is_expected.to include('GIT={{config pair.author.name }}')
      is_expected.to include('GIT={{config pair.committer.email }}')
      is_expected.to include('GIT={{config pair.committer.name }}')
    end
  end

  describe 'proxy commits' do
    context 'when no pair is set yet' do
      subject { pair 'commit --amend' }

      it 'call git commit with same params' do
        is_expected.to include('GIT={{commit --amend')
      end
    end

    context 'when pair is actually just one person' do
      subject { pair 'vnegrisolo; pair commit --amend' }

      it 'call git commit with same params' do
        is_expected.to include('GIT={{commit --amend --author=')
      end
    end

    context 'when pair is actually just one person' do
      subject { pair 'vnegrisolo hashrocketer; pair commit --amend' }

      it 'call git commit with same params' do
        is_expected.to include('GIT={{commit --amend --author=')
      end

      context 'when a second commit is made' do
        subject { pair 'vnegrisolo hashrocketer; pair commit --amend' }

        it 'calls git commit with original author and committer swapped' do
          is_expected.to include('GIT={{commit --amend --author=')
        end
      end
    end
  end

end
