# Bucky-Core

## Overview

Bucky is a testing framework that supports Web System Testing Life Cycle.

## Feature

* Tests run in parallel
* Re-run function
* Codes of test suite are of the form YAML
* Multiple browser support (Chrome)
* Some Test Categories support
  * E2E Tests including JavaScript Error Check
  * LINK Status Tests in web page
* Test Report by [bucky-management](https://github.com/lifull-dev/bucky-management)

### Set connection infomation for database

```bash
export BUCKY_DB_USERNAME="{your database username}"
export BUCKY_DB_PASSWORD="{your database password}"
export BUCKY_DB_HOSTNAME="{your database hostname}"
export BUCKY_DB_NAME="{your database name}"
```

## Usage

### Install
```bash
gem install bucky-core
```

### Run test

```bash
# Examples:
# Select test categories
bucky run --test_category e2e
bucky run -t e2e
bucky run -t linkstatus
# Filter test condition
bucky run --test_category e2e --device sp --priority high
bucky run --test_category e2e --case login
bucky run --test_category e2e -D tablet --priority high
bucky run --test_category e2e -D pc --label foo,bar,baz --priority high
# For debug (-d,--debug: not insert test result)
bucky run -t e2e -d
# Re test for flaky test
bucky run --test_category e2e --re_test_count 3
bucky run -t linkstatus -s bukken_detail -D pc -r 3
# Rerun from job id
bucky rerun -j 100
bucky rerun -j 100 -r 3
# If you want to use environment variables in test code
FOO=foo bucky run ...

# Options:
    -t TEST_CATEGORY,                e.g. --test_category e2e, -t e2e
        --test_category
    -s, --suite_name SUITE_NAME
    -S, --service SERVICE
    -c, --case CASE_NAME
    -D, --device DEVICE
    -p, --priority PRIORITY
    -r RE_TEST_COUNT,
        --re_test_count
    -d --debug Not Insert TestResult
    -j, --job_id JOB_ID (works only with bucky rerun)
    -l, --label LABEL_NAME
    -m, --link_check_max_times (works only with category linkstatus)
```

### Implemente test code

```bash
# Make test code dir
bucky new {test project name}

# Make test service dir
bucky make service {service_name}

# Make pageobject(rb) and part(yml)
## PC
bucky make page {page_name} --service {service_name} --device pc
## Smart phone
bucky make page {page_name} --service {service_name} --device sp
## Tablet
bucky make page {page_name} --service {service_name} --device tablet
```

#### Sample e2e test_code.yml

you can use erb notation

```yaml
desc: suite description
device: pc
service: service_name
priority: high
test_category: e2e
labels: test_label_foo
setup_each:
  procs:
    - proc: login
      exec:
        operate: go
        url: https://example.com/login
teardown_each:
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
          page: next_page
          part:
            locate: many_links
            num: 0
      - proc: switch tab
        exec:
          operate: switch_next_window
      - proc: select by dropdown
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
      - exec: # For debug
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

you can use erb notation

```yaml
desc: suite description
device: pc
service: service_name
priority: high
test_category: linkstatus
exclude_urls:
  - https://example.com/fuga/?hoge=1 # PERFECT MATCHING
  - https://example.com/fuga/* # PARTIAL MATCHING
cases:
  - case_name: test_code_1 # Suite filename + number
    desc: statuscheck for top page
    urls:
        - https://example.com/
        - https://www.example.com/
  - case_name: test_code_2 # Suite filename + number
    desc: statuscheck for detail page
    urls:
        - https://example.com/detail/1
        - <%= ENV['FQDN'] %>/detail/2 # Using erb notation to get environment variable
```

# Development

## Development(only executing debug-mode)

```bash
git clone git@github.com:lifull-dev/bucky-core.git
cd bucky-core
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

