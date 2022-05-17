#!/usr/bin/env bats

setup() {
  cd /bucky-core/system_testing/test_bucky_project
}

@test "#1,#3 After executing linkstatus on pc , results contain target base url, no failures/errors and exit code is 0." {
  run bucky run -t linkstatus -d -D pc -c pc_link_1
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*http://bucky\.net.*") -ne 0 ]
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "#2 After executing linkstatus on pc , results contain target link url and no failures/errors." {
  run bucky run -t linkstatus -d -D pc -c pc_link_1
  [ $(expr "$output" : ".*http://bucky\.net/test_page.html.*") -ne 0 ]
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "#4 After executing linkstatus failed test, exit code is 1" {
  run bucky run -t linkstatus -d -D pc -c pc_link_2
  [ $status -eq 1 ]
}

@test "#5 After executing linkstatus on sp , results have no failures nor errors" {
  run bucky run -t linkstatus -d -D sp -c sp_link_1
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}