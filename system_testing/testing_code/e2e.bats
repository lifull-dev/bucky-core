#!/usr/bin/env bats

setup() {
  cd /bucky-core/system_testing/test_bucky_project
}

@test "[e2e] #01 After executing e2e operate go, results have no failures nor errors" {
  run bucky run -t e2e -d -D pc -c pc_e2e_1
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[e2e] #02 After executing e2e verify assert_title, results contain verify words, no failures/errors and exit code is 0" {
  run bucky run -t e2e -d -D pc -c pc_e2e_1
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*:verify.*assert_title.*") -ne 0 ]
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[e2e] #03 After executing e2e verify assert_title, results contain verify words and 1 failure and exit code is 1" {
  run bucky run -t e2e -d -D pc -c pc_e2e_2
  [ $status -eq 1 ]
  [ $(expr "$output" : ".*:verify.*assert_title.*") -ne 0 ]
  [ $(expr "$output" : ".*1 failures.*") -ne 0 ]
}

@test "[e2e] #04 After executing e2e on pc , results contain 'Linux' and no failures/errors." {
  run bucky run -t e2e -d -D pc -c pc_e2e_3
  [ $(expr "$output" : ".*Linux.*") -ne 0 ]
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[e2e] #05 After executing e2e on sp , results contain 'iPhone' and no failures/errors." {
  run bucky run -t e2e -d -D sp -c sp_e2e_1
  [ $(expr "$output" : ".*iPhone.*") -ne 0 ]
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[e2e] #06 After executing e2e on tablet , results contain 'iPad' and no failures/errors." {
  run bucky run -t e2e -d -D tablet -c tablet_e2e_1
  [ $(expr "$output" : ".*iPad.*") -ne 0 ]
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[e2e] #07 After executing e2e operate go with setup each, results have no failures nor errors" {
  run bucky run -d -c setup_each_pc_e2e_1
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[e2e] #08 After executing e2e operate go with teardown each, results have no failures nor errors" {
  run bucky run -d -c teardown_each_pc_e2e_1
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[e2e] #09 When setup and teardown is added, multiple test cases execute normally, results have no failures nor errors" {
  run bucky run -d -s setup_teardown_each_pc_e2e
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[e2e] #10 When 'when condition' is added, results have no failures nor errors" {
  export STAGE=development
  run bucky run -t e2e -d -D pc -c pc_e2e_4
  [ $(expr "$output" : ".*click.*") -ne 0 ]
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[e2e] #11 When 'when condition' is not added, results have no click procedure" {
  run bucky run -t e2e -d -D pc -c pc_e2e_4
  [ $(expr "$output" : ".*click.*") -eq 0 ]
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[e2e] #12 When 'different when condition' is added, results have no click procedure" {
  export STAGE=staging
  run bucky run -t e2e -d -D pc -c pc_e2e_4
  [ $(expr "$output" : ".*click.*") -eq 0 ]
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[e2e] #13 When click second element from scenario, results have no failures nor errors" {
  run bucky run -t e2e -d -D pc -c pc_e2e_5
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[e2e] #14 When click element from PageObject file, results have no failures nor errors" {
  run bucky run -t e2e -d -D pc -c pc_e2e_6
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[e2e] #15 When click second element from PageObject file, results have no failures nor errors" {
  run bucky run -t e2e -d -D pc -c pc_e2e_7
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[e2e] #16 When click element from Verification file, results have no failures nor errors" {
  run bucky run -t e2e -d -D pc -c pc_e2e_8
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[e2e] #17 When click second element from Verification file, results have no failures nor errors" {
  run bucky run -t e2e -d -D pc -c pc_e2e_9
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}
