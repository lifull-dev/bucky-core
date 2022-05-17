#!/usr/bin/env bats

BUCKY_PROJECT_NAME=bats_test
TEST_SERVICE=test_service

setup() {
  rm -rf /tmp/$BUCKY_PROJECT_NAME
  cd /tmp/
  bucky new $BUCKY_PROJECT_NAME
}

teardown() {
  rm -rf /tmp/$BUCKY_PROJECT_NAME
}

@test "#1 After executing 'new' command, expected files and directories are created" {
  run diff /bucky-core/template/new/ /tmp/$BUCKY_PROJECT_NAME
  [ $status -eq 0 ]
}

@test "#2 After executing 'make service' command, expected directory is created" {
  cd /tmp/$BUCKY_PROJECT_NAME
  bucky make service $TEST_SERVICE
  run ls /tmp/$BUCKY_PROJECT_NAME/services/$TEST_SERVICE
  [ $status -eq 0 ]
}

@test "#3 After executing 'make page' command, expected page and parts file are created" {
  cd /tmp/$BUCKY_PROJECT_NAME
  bucky make service $TEST_SERVICE
  bucky make page test_page --service $TEST_SERVICE --device pc
  run ls /tmp/$BUCKY_PROJECT_NAME/services/$TEST_SERVICE/pc/pageobject/test_page.rb
  [ $status -eq 0 ]
  run ls /tmp/$BUCKY_PROJECT_NAME/services/$TEST_SERVICE/pc/parts/test_page.yml
  [ $status -eq 0 ]
}

@test "#4 After executing undefined command, show error message and exit" {
  cd /tmp/$BUCKY_PROJECT_NAME
  run bucky hoge fuga
  [ $(expr "$output" : ".*Invalid command error.*") -ne 0 ]
}
