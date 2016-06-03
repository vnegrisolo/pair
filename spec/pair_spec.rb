require 'spec_helper'

RSpec.describe 'pair', type: :shell do

  before { shell.load 'pair.sh' }

  let(:git_mock) { shell.expect(:git) }
  let(:curl_mock) { shell.expect(:curl) }

  describe 'status' do
    subject { shell.run 'pair' }

    it 'prints the author and committer' do
      git_mock.with('config --get pair.author').and_return('bill')
      git_mock.with('config --get pair.committer').and_return('karen')

      git_mock.with('config --global --get pair.bill.name').and_return('Bill Jr')
      git_mock.with('config --global --get pair.bill.email').and_return('bill@mail.com')
      git_mock.with('config --global --get pair.karen.name').and_return('Karen Bright')
      git_mock.with('config --global --get pair.karen.email').and_return('karen@mail.com')
      git_mock.with('log -10 --pretty=format:%h => %Cgreen%an %Creset=> %Cblue%cn %Creset=> %s')

      is_expected.to include("Author    => \e[32mbill\e[m")
      is_expected.to include("Committer => \e[34mkaren\e[m")
    end
  end

  describe 'reset' do
    subject { shell.run 'pair reset' }

    before do
      shell.export('GIT_AUTHOR_NAME', 'foo')
      shell.export('GIT_AUTHOR_EMAIL', 'foo')
      shell.export('GIT_COMMITTER_NAME', 'foo')
      shell.export('GIT_COMMITTER_EMAIL', 'foo')
    end

    it 'resets pair config' do
      git_mock.with('config --remove-section pair')

      is_expected.to_not include('GIT_AUTHOR_NAME')
      is_expected.to_not include('GIT_AUTHOR_EMAIL')
      is_expected.to_not include('GIT_COMMITTER_NAME')
      is_expected.to_not include('GIT_COMMITTER_EMAIL')
    end
  end

  describe 'confirure' do
    before { git_mock.with('config --remove-section pair') }

    context 'when the user does not have email or name' do
      subject { shell.run 'pair bob' }

      before do
        git_mock.with('config --global --get pair.bob.name')
        git_mock.with('config --global --get pair.bob.email')
      end

      context 'when user does not have email/name on github' do
        before do
          curl_mock.with('https://api.github.com/users/bob')
            .and_return(fixture(:github_user_bob_incomplete))
        end

        context 'when the user types email/name' do
          before { shell.type 'bob@mail.com', 'Bob' }

          it 'call git commit with same params' do
            git_mock.with('config --global pair.bob.name Bob')
            git_mock.with('config --global pair.bob.email bob@mail.com')
            git_mock.with('config pair.author bob')
          end
        end

        context 'when the user does not type email/name' do
          before { shell.type '', '' }

          it 'call git commit with same params' do
            is_expected.to include('ERROR')
            is_expected.to include('You need to set Name and Email for bob')
          end
        end
      end
    end

    context 'when the user has cached email and name' do
      subject { shell.run 'pair bill' }

      it 'call git commit with same params' do
        git_mock.with('config --global --get pair.bill.name').and_return('Bill Jr')
        git_mock.with('config --global --get pair.bill.email').and_return('bill@mail.com')

        git_mock.with('config --global pair.bill.name Bill Jr')
        git_mock.with('config --global pair.bill.email bill@mail.com')
        git_mock.with('config pair.author bill')
      end
    end

    context 'when pair is set with just one user' do
      subject { shell.run 'pair bill' }

      it 'call git commit with same params' do
        git_mock.with('config --global --get pair.bill.name')
        git_mock.with('config --global --get pair.bill.email')

        curl_mock.with('https://api.github.com/users/bill')
          .and_return(fixture(:github_user_bill))

        git_mock.with('config --global pair.bill.name Bill Jr')
        git_mock.with('config --global pair.bill.email bill@mail.com')
        git_mock.with('config pair.author bill')
      end
    end

    context 'when pair is set with two users' do
      subject { shell.run 'pair bill karen' }

      it 'call git commit with same params' do
        git_mock.with('config --global --get pair.bill.name')
        git_mock.with('config --global --get pair.bill.email')
        git_mock.with('config --global --get pair.karen.name')
        git_mock.with('config --global --get pair.karen.email')

        curl_mock.with('https://api.github.com/users/bill')
          .and_return(fixture(:github_user_bill))
        curl_mock.with('https://api.github.com/users/karen')
          .and_return(fixture(:github_user_karen))

        git_mock.with('config --global pair.bill.name Bill Jr')
        git_mock.with('config --global pair.bill.email bill@mail.com')
        git_mock.with('config pair.author bill')
        git_mock.with('config --global pair.karen.name Karen Bright')
        git_mock.with('config --global pair.karen.email karen@mail.com')
        git_mock.with('config pair.committer karen')
      end
    end
  end

  describe 'proxy commits' do
    subject { shell.run 'pair commit --amend' }

    context 'when no pair is set yet' do
      it 'call git commit with same params' do
        git_mock.with('config --get pair.author')
        git_mock.with('config --get pair.committer')

        git_mock.with('config --global --get pair..name')
        git_mock.with('config --global --get pair..email')
        git_mock.with('config --global --get pair..name')
        git_mock.with('config --global --get pair..email')

        git_mock.with('commit --amend')
        is_expected.to include("GIT_AUTHOR_NAME=\n")
        is_expected.to include("GIT_AUTHOR_EMAIL=\n")
        is_expected.to include("GIT_COMMITTER_NAME=\n")
        is_expected.to include("GIT_COMMITTER_EMAIL=\n")
      end
    end

    context 'when pair is actually is set with one person' do
      it 'call git commit with same params' do
        git_mock.with('config --get pair.author').and_return('bill')
        git_mock.with('config --get pair.committer')

        git_mock.with('config --global --get pair.bill.name').and_return('Bill Jr')
        git_mock.with('config --global --get pair.bill.email').and_return('bill@mail.com')
        git_mock.with('config --global --get pair..name')
        git_mock.with('config --global --get pair..email')

        git_mock.with('commit --amend')
        is_expected.to include("GIT_AUTHOR_NAME=Bill Jr\n")
        is_expected.to include("GIT_AUTHOR_EMAIL=bill@mail.com\n")
        is_expected.to include("GIT_COMMITTER_NAME=\n")
        is_expected.to include("GIT_COMMITTER_EMAIL=\n")
      end
    end

    context 'when pair is actually is set with two people' do
      it 'call git commit with same params' do
        git_mock.with('config --get pair.author').and_return('bill')
        git_mock.with('config --get pair.committer').and_return('karen')

        git_mock.with('config --global --get pair.bill.name').and_return('Bill Jr')
        git_mock.with('config --global --get pair.bill.email').and_return('bill@mail.com')
        git_mock.with('config --global --get pair.karen.name').and_return('Karen Bright')
        git_mock.with('config --global --get pair.karen.email').and_return('karen@mail.com')

        git_mock.with('commit --amend')

        git_mock.with('config pair.author karen')
        git_mock.with('config pair.committer bill')
        is_expected.to include("GIT_AUTHOR_NAME=Bill Jr\n")
        is_expected.to include("GIT_AUTHOR_EMAIL=bill@mail.com\n")
        is_expected.to include("GIT_COMMITTER_NAME=Karen Bright\n")
        is_expected.to include("GIT_COMMITTER_EMAIL=karen@mail.com\n")
      end
    end
  end
end
