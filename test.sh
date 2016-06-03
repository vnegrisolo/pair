#!/bin/sh

source pair.sh

CURRENT_FOLDER=$(pwd)
TEST_FOLDER='/tmp/pair_test_tpm'

rm -rf $TEST_FOLDER
mkdir $TEST_FOLDER
cd $TEST_FOLDER
git init

pair dev1 dev2 <<< $'dev1@mail.com\nDev1 Name\ndev2@mail.com\nDev2 Name'

touch file.md; git add .; pair commit -am 'First commit on master'
git checkout -b new-feature;

echo "change" >> file.md; pair commit -am 'Second commit'
echo "change" >> file.md; pair commit -am ''
echo "change" >> file.md; pair commit -am 'Third commit'
echo "change" >> file.md; pair commit -am 'Forth commit'
echo "change" >> file.md; pair commit -am 'Fifth commit'
echo "change" >> file.md; pair commit -am 'Sixth commit'

pair
echo "reseting"
pair reset
pair

grep -A 2 'pair' ~/.gitconfig .git/config

cd $CURRENT_FOLDER
