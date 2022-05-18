#!/usr/bin/env bats

setup() {
  cd /bucky-core/system_testing/test_bucky_project
}

@test "[linkstatus] #1, #3 After executing linkstatus on pc, results contain target base url, no failures/errors and exit code is 0." {
  run bucky run -t linkstatus -d -D pc -c pc_link_1
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*http://bucky\.net.*") -ne 0 ]
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[linkstatus] #2 After executing linkstatus on pc, results contain target link url and no failures/errors." {
  run bucky run -t linkstatus -d -D pc -c pc_link_1
  [ $(expr "$output" : ".*http://bucky\.net/test_page.html.*") -ne 0 ]
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[linkstatus] #4 After executing linkstatus failed test, exit code is 1" {
  run bucky run -t linkstatus -d -D pc -c pc_link_2
  [ $status -eq 1 ]
}

@test "[linkstatus] #5 After executing linkstatus on sp, results have no failures nor errors" {
  run bucky run -t linkstatus -d -D sp -c sp_link_1
  [ $(expr "$output" : ".*0 failures, 0 errors,.*") -ne 0 ]
}

@test "[linkstatus] #6 After executing linkstatus with excluding by normal, results not contain target link url and no failures/errors." {
  run bucky run -t linkstatus -d -D pc -c pc_link_exclude_normal_1
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*http://bucky\.net/test_page.html.*") -eq 0 ]
}

@test "[linkstatus] #7 After executing linkstatus with excluding by asterisk, results not contain target link url and no failures/errors." {
  run bucky run -t linkstatus -d -D pc -c pc_link_exclude_asterisk_1
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*http://bucky\.net/test_page.html.*") -eq 0 ]
}

@test "[linkstatus] #8 After executing linkstatus with excluding by regex, results not contain target link url and no failures/errors." {
  run bucky run -t linkstatus -d -D pc -c pc_link_exclude_regex_1
  [ $status -eq 0 ]
  [ $(expr "$output" : ".*http://bucky\.net/test_page.html.*") -eq 0 ]
}

