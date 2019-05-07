# Bucky-management

## What is this example doing
This example will show you how to connect to Bucky-management and how to get test report automatically.

## Before starting
Start Bucky-management with docker-compose.yml.
See [READEME](https://github.com/lifull-dev/bucky-management) in Bucky-management if you start it at first time.
```bash
# Execute this command in Bucky-management directory
docker-compose -f docker-compose.yml up --build -d
```
## 1. Move to you test project directory
- You can see how to make test project in [example/hands-on](https://github.com/lifull-dev/bucky-core/tree/master/example/hands-on)
```bash
# In this example, you can just stay in example/bucky-management
cd {test project name}
```

## 2. Sets connect information to DB
- Use default value as following if you didn't change anything in Bucky-management's docker-compose.yml
- Database name is according to what you set in RAILS_ENV when startup Bcuky-management
```
## config/test_db_config.yml ##

:test_db:
  :bucky_test:
    :username: root
    :password: password
    :database: bucky_test # When $RAILS_ENV=test
    :host: 127.0.0.1
    :port: 3306
    :adapter: :mysql
```

## 3. Execute test case without -d option
It will save test result into DB executing without debug option.
```bash
# These test case is already made. You can just execute them in example/bucky-management
bucky run -t e2e -D pc -c search_and_assert_1
bucky run -t linkstatus -D pc -c github_top_1
```

## 4. Check your test report
Open your browser http://localhost

You will see two result shown in top page.

## At last
Congratulations!! You have just made your test report.

There are lots of information shown in reports.
It shows more information in each report's detail, e.g. pass rate, NG cases name, NG error message and so on.

Enjoy your test with Bucky!!
