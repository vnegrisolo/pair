#!/bin/sh

source pair.sh

CURRENT_FOLDER=$(pwd)
TEST_FOLDER='/tmp/pair_test_tpm'

rm -rf $TEST_FOLDER
mkdir $TEST_FOLDER
cd $TEST_FOLDER
git init

pair vnegrisolo other-dev <<< $'dev@mail.com\nDev Name'
touch file.md; git add .; pair commit -am 'First commit'
echo "change" >> file.md; pair commit -am 'Second commit'
echo "change" >> file.md; pair commit -am ''
echo "change" >> file.md; pair commit -am 'Third commit'

pair

cd $CURRENT_FOLDER
