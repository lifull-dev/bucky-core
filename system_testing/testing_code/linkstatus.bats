#!/usr/bin/env bats

setup() {
  cd /bucky-core/system_testing/test_bucky_project
}

teardown() {
  # No failures and errors
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "#10,#12 After executing linkstatus on pc , results contain target base url and no failures/errors." {
  run bucky run -t linkstatus -d -D pc -c pc_link_1
  [ $(expr "$output" : ".*http://bucky\.net.*") -ne 0 ]
}

@test "#11 After executing linkstatus on pc , results contain target link url and no failures/errors." {
  run bucky run -t linkstatus -d -D pc -c pc_link_1
  [ $(expr "$output" : ".*http://bucky\.net/test_page.html.*") -ne 0 ]
}

@test "#13 After executing linkstatus on sp , results have no failures nor errors" {
  run bucky run -t linkstatus -d -D sp -c sp_link_1
}