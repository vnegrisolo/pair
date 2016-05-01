require 'spec_helper'

RSpec.describe 'pair', type: :shell do

  let(:shell) { Shell.new(:curl, :git) }

  after do
    is_expected.to_not include('Should Be Mocked')
  end

  describe 'status' do
    subject { shell.run 'pair' }

    it 'prints the author and committer' do
      shell.allow(:git).with('config --global --get pair.author.name')
        .and_return('Bill Jr')
      shell.allow(:git).with('config --global --get pair.author.email')
        .and_return('bill@mail.com')
      shell.allow(:git).with('config --global --get pair.committer.name')
        .and_return('Karen Bright')
      shell.allow(:git).with('config --global --get pair.committer.email')
        .and_return('karen@mail.com')
      shell.allow(:git).with('log -10 --pretty=format:%h => %Cgreen%an %Creset=> %Cblue%cn %Creset=> %s')

      is_expected.to include('Author    =>')
      is_expected.to include('Bill Jr <bill@mail.com>')
      is_expected.to include('Committer =>')
      is_expected.to include('Karen Bright <karen@mail.com>')
    end
  end

  describe 'reset' do
    subject { shell.run 'pair', 'reset' }

    it 'resets pair config' do
      shell.allow(:git).with('config --global --remove-section pair.author')
      shell.allow(:git).with('config --global --remove-section pair.committer')
    end
  end

  describe 'confirure' do

    before do
      shell.allow(:git).with('config --global --unset pair.author.name')
      shell.allow(:git).with('config --global --unset pair.author.email')
      shell.allow(:git).with('config --global --unset pair.committer.name')
      shell.allow(:git).with('config --global --unset pair.committer.email')
    end

    context 'when the user does not have email or name' do
      subject { shell.run 'pair', 'bob' }

      it 'call git commit with same params' do
        shell.allow(:git).with('config --global --get pair.bob.name')
        shell.allow(:git).with('config --global --get pair.bob.email')

        shell.allow(:curl).with('https://api.github.com/users/bob')
          .and_return(fixture(:github_user_bob_incomplete))

        is_expected.to include('ERROR')
        is_expected.to include('You need to set Name and Email for bob on Github, or run manually:')
        is_expected.to include("git config --global pair.author.name 'Your Name'")
        is_expected.to include("git config --global pair.author.email 'your@email.com'")
      end
    end

    context 'when the user has set the email and name already' do
      subject { shell.run 'pair', 'bill' }

      it 'call git commit with same params' do
        shell.allow(:git).with('config --global --get pair.bill.name')
          .and_return('Bill Jr')
        shell.allow(:git).with('config --global --get pair.bill.email')
          .and_return('bill@mail.com')

        shell.allow(:git).with('config --global pair.bill.name Bill Jr')
        shell.allow(:git).with('config --global pair.bill.email bill@mail.com')
        shell.allow(:git).with('config --global pair.author.name Bill Jr')
        shell.allow(:git).with('config --global pair.author.email bill@mail.com')
      end
    end

    context 'when pair is set with just one user' do
      subject { shell.run 'pair', 'bill' }

      it 'call git commit with same params' do
        shell.allow(:git).with('config --global --get pair.bill.name')
        shell.allow(:git).with('config --global --get pair.bill.email')

        shell.allow(:curl).with('https://api.github.com/users/bill')
          .and_return(fixture(:github_user_bill))

        shell.allow(:git).with('config --global pair.bill.name Bill Jr')
        shell.allow(:git).with('config --global pair.bill.email bill@mail.com')
        shell.allow(:git).with('config --global pair.author.name Bill Jr')
        shell.allow(:git).with('config --global pair.author.email bill@mail.com')
      end
    end

    context 'when pair is set with two users' do
      subject { shell.run 'pair', 'bill karen' }

      it 'call git commit with same params' do
        shell.allow(:git).with('config --global --get pair.bill.name')
        shell.allow(:git).with('config --global --get pair.bill.email')
        shell.allow(:git).with('config --global --get pair.karen.name')
        shell.allow(:git).with('config --global --get pair.karen.email')

        shell.allow(:curl).with('https://api.github.com/users/bill')
          .and_return(fixture(:github_user_bill))
        shell.allow(:curl).with('https://api.github.com/users/karen')
          .and_return(fixture(:github_user_karen))

        shell.allow(:git).with('config --global pair.bill.name Bill Jr')
        shell.allow(:git).with('config --global pair.bill.email bill@mail.com')
        shell.allow(:git).with('config --global pair.author.name Bill Jr')
        shell.allow(:git).with('config --global pair.author.email bill@mail.com')
        shell.allow(:git).with('config --global pair.karen.name Karen Bright')
        shell.allow(:git).with('config --global pair.karen.email karen@mail.com')
        shell.allow(:git).with('config --global pair.committer.name Karen Bright')
        shell.allow(:git).with('config --global pair.committer.email karen@mail.com')
      end
    end
  end

  describe 'proxy commits' do
    subject { shell.run 'pair', 'commit --amend' }

    context 'when no pair is set yet' do
      it 'call git commit with same params' do
        shell.allow(:git).with('config --global --get pair.author.name')
        shell.allow(:git).with('config --global --get pair.author.email')
        shell.allow(:git).with('config --global --get pair.committer.name')
        shell.allow(:git).with('config --global --get pair.committer.email')

        shell.allow(:git).with('commit --amend')
      end
    end

    context 'when pair is actually is set with one person' do
      it 'call git commit with same params' do
        shell.allow(:git).with('config --global --get pair.author.name')
          .and_return('Bill Jr')
        shell.allow(:git).with('config --global --get pair.author.email')
          .and_return('bill@mail.com')
        shell.allow(:git).with('config --global --get pair.committer.name')
        shell.allow(:git).with('config --global --get pair.committer.email')

        shell.allow(:git).with('commit --amend')
      end
    end

    context 'when pair is actually is set with two people' do
      it 'call git commit with same params' do
        shell.allow(:git).with('config --global --get pair.author.name')
          .and_return('Bill Jr')
        shell.allow(:git).with('config --global --get pair.author.email')
          .and_return('bill@mail.com')
        shell.allow(:git).with('config --global --get pair.committer.name')
          .and_return('Karen Bright')
        shell.allow(:git).with('config --global --get pair.committer.email')
          .and_return('karen@mail.com')

        shell.allow(:git).with('commit --amend')

        shell.allow(:git).with('config --global pair.author.name Karen Bright')
        shell.allow(:git).with('config --global pair.author.email karen@mail.com')
        shell.allow(:git).with('config --global pair.committer.name Bill Jr')
        shell.allow(:git).with('config --global pair.committer.email bill@mail.com')
      end
    end
  end
end
