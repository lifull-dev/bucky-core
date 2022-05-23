# Bucky-Core
[![Gem Version](https://badge.fury.io/rb/bucky-core.svg)](https://badge.fury.io/rb/bucky-core) [![CircleCI](https://circleci.com/gh/lifull-dev/bucky-core/tree/master.svg?style=svg)](https://circleci.com/gh/lifull-dev/bucky-core/tree/master) [![Maintainability](https://api.codeclimate.com/v1/badges/adf9599d98a55ac87a2e/maintainability)](https://codeclimate.com/github/lifull-dev/bucky-core/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/adf9599d98a55ac87a2e/test_coverage)](https://codeclimate.com/github/lifull-dev/bucky-core/test_coverage)

## Overview
Bucky-core can run test code which is written in YAML. End-to-End test (working with Selenium) and Linkstatus test (HTTP status check) are supported in default. Page object model pattern and page based element management is the main concept in Bucky-core.  You can create scenarios and execute it easily by using Bucky-core.

When working with [Bucky-management](https://github.com/lifull-dev/bucky-management), Bucky-core can also record test results. You can make test results visualization by using Bucky-management.

## Feature

* Run tests in parallel
* Re-run tests which failed last time
* Support test code in YAML
* Multiple browser supported (currently only Chrome is supported)
* Customizable test categories
  * [Default] E2E: E2E (End to End) tests
  * [Default] Linkstatus: http status code check in web page
* Making test report with [Bucky-management](https://github.com/lifull-dev/bucky-management)


## Setup

Checkout Hands-on in example to get a quick start.
* [bucky-core/example/hands-on](https://github.com/lifull-dev/bucky-core/tree/master/example/hands-on)

### Install
```bash
gem install bucky-core
```

### Implement test code
* Use snake case for naming
```bash
# Make project directory
bucky new {your_project_name}

# Move into project directory
# It's the working directory when execute Bucky command
cd {your_project_name}

# Make service directory
bucky make service {your_service_name}

# Make page object(.rb) and part(.yml) in device directory
## PC
bucky make page {page_name} --service {your_service_name} --device pc
## Smart phone
bucky make page {page_name} --service {your_service_name} --device sp
## Tablet
bucky make page {page_name} --service {your_service_name} --device tablet

# Write your test code in following directory:
# services/{your_service_name}/{device}/scenarios/e2e/
# services/{your_service_name}/{device}/scenarios/linkstatus/

# Some samples are at bottom of Usage
vim services/first_serive/pc/scenarios/e2e/test_code.yml
```

### Set connecting information for database

```bash
export BUCKY_DB_USERNAME="{your database username}"
export BUCKY_DB_PASSWORD="{your database password}"
export BUCKY_DB_HOSTNAME="{your database hostname}"
export BUCKY_DB_NAME="{your database name}"
```

## Usage
You can find some examples in here!
* [bucky-core/example](https://github.com/lifull-dev/bucky-core/blob/master/example)

You should start Selenium Chrome driver first. And you can find how to start Selenium Chrome driver by Docker in [SeleniumHQ/docker-selenium](https://github.com/SeleniumHQ/docker-selenium).
### Run test
```bash
# Condition filter using option
bucky run --test_category e2e --device sp --priority high
bucky run --test_category e2e --case login
bucky run --test_category e2e -D tablet --priority high
bucky run --test_category e2e -D pc --label foo,bar,baz --priority high
# Run test in debug mode (It won't insert test result into DB)
bucky run -t e2e -d
# Use -r to run more times for flaky test
# It will only run tests that failed in last count
bucky run --test_category e2e --re_test_count 3
bucky run -t linkstatus -s bukken_detail -D pc -r 3
# Use environment variables in test
ENV_FOO=foo bucky run -t e2e -d

# Options:
    -d, --debug # Won't insert test result into DB
    -t, --test_category TEST_CATEGORY
    -s, --suite_name SUITE_NAME
    -S, --service SERVICE
    -c, --case CASE_NAME
    -D, --device DEVICE
    -p, --priority PRIORITY
    -r, --re_test_count RE_TEST_COUNT # How many round you run tests
    -l, --label LABEL_NAME
    -m, --link_check_max_times MAX_TIMES # Works only with which category is linkstatus
    -o, --out JSON_OUTPUT_FILE_PATH # Output summary report by json
```

### Rerun test
```bash
# Only work with saved test result
# Rerun from job id
bucky rerun -j 100
bucky rerun -j 100 -r 3

# Options:
    -d, --debug # Won't insert test result into DB
    -r, --re_test_count RE_TEST_COUNT # How many round you run tests
    -j, --job_id JOB_ID
```

#### Sample E2E test_code.yml

* You can use erb notation in test code
* [Operation list](https://github.com/lifull-dev/bucky-core/blob/master/lib/bucky/test_equipment/user_operation/user_operation_helper.rb)
* [Verification list](https://github.com/lifull-dev/bucky-core/blob/master/lib/bucky/test_equipment/verifications/e2e_verification.rb)

```yaml
desc: suite description
device: pc
service: service_name
priority: high
test_category: e2e
labels: test_label_foo
setup_each: # These procedures will be executed before every case
  procs:
    - proc: login
      exec:
        operate: go
        url: https://example.com/login
teardown_each: # These procedures will be executed after every case
  procs:
    - proc: login
      exec:
        operate: go
        url: https://example.com/logout

cases:
  - case_name: test_code_1 # Suite filename + number
    func: inquire button
    desc: case description
    labels:
      - test_label_bar
      - test_label_baz
    procs:
      - proc: open page
        exec:
          operate: go
          url: http://example.com/
      - proc: open page
        exec:
          operate: go
          url: <%= ENV['FQDN'] %>/results # Using erb notation to get environment variable
      - proc: element click
        exec:
          operate: click
          page: top
          part: next_page
        when: <%= ENV['STAGE'] == development %> # Executing this proc when this condition is true
      - proc: one of elements click # Using xpaths
        exec:
          operate: click
          page: next_page # This file is at services/service_name/pc/parts/next_page.yml
          part:
            locate: many_links #  many_links is a xpath that describe in services/service_name/pc/parts/next_page.yml
            num: 0 # You can choose number of element when xpath have multiple elements
      - proc: switch tab
        exec:
          operate: switch_next_window
      - proc: select by drop down
        exec:
          operate: choose
          page: input_page
          part: age
          text: 20
      - proc: alert accept
        exec:
          operate: alert_accept
      - exec:
          operate: wait
          sec: 2
      - exec: # You can stop your test by using stop operator
          operate: stop
      - proc: check message
        exec:
          verify: assert_text
          page: input_thanks
          part: complete_message
          expect: done
      - proc: check message
        exec:
          verify: assert_contained_text
          page: input_thanks
          part: complete_message
          expect: done
```

#### Sample linkstatus test_code.yml

* Linkstatus will check every \<a> tag's http response in url

```yaml
desc: suite description
device: pc
service: service_name
priority: high
test_category: linkstatus
exclude_urls:
  - https://example.com/fuga/?hoge=1 # PERFECT MATCHING
  - https://example.com/fuga/* # PARTIAL MATCHING
  - /https://example.com/.*\.html/ # REGULAR EXPRESSION MATCHING
cases:
  - case_name: test_code_1 # Suite filename + number
    desc: status check for top page
    urls:
        - https://example.com/
        - https://www.example.com/
  - case_name: test_code_2
    desc: status check for detail page
    urls:
        - https://example.com/detail/1
        - <%= ENV['FQDN'] %>/detail/2 # Using erb notation to get environment variable
```

# Development

## Development
Should always execute bucky run with -d option
```bash
git clone git@github.com:lifull-dev/bucky-core.git
cd bucky-core
# clone from some test code
git clone git@github.com:${sample_test_code_owner}/${sample_testcode}.git .sample
docker-compose -f docker-compose.dev.yml up --build -d
docker-compose -f docker-compose.dev.yml down
```

## Development with bucky-management
You should start bucky-management first.

```bash
git clone git@github.com:lifull-dev/bucky-core.git
cd bucky-core
git clone git@github.com:${sample_test_code_owner}/${sample_testcode}.git .sample
docker-compose -f docker-compose.dev-with-bm.yml up --build -d
docker-compose -f docker-compose.dev-with-bm.yml down
```

## Contributing

* [Naoto Kishino](https://github.com/kishinao)
* [Rikiya Hikimochi](https://github.com/hikimocr)
* [Jye Ruey](https://github.com/rueyjye)
* [Seiya Sato](https://github.com/satose)
* [Hikaru Fukuzawa](https://github.com/FukuzawaHikaru)
* [Naoki Nakano](https://github.com/NakanoNaoki)
