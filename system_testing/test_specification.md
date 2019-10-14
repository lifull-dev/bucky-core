# Procedures of test execution

```bash
docker-compose -f docker-compose.system-test.yml up --build -d

docker exec bucky-core bats /bucky-core/system_testing/testing_code/
# OR
docker exec bucky-core bats /bucky-core/system_testing/testing_code/command.bats

docker-compose -f docker-compose.system-test.yml down
```

# Test case specification
※ Only Japanese now.
※ テストケースNo.はbatsのケース説明部分に記載し、対応づけを行う

| テスト条件 | テスト観点 | テストケース<br/>No. | テストケース | テスト手順 | 期待結果 |
|:--|:--|--:|:--|:--|:--|
| E2Eテスト実行機能 | Operateが正常に実行できるか<br/>・シナリオコードに実装されたOperateが実行できること<br/>・clickして遷移できること ※1種類のOperateができればOK<br/>ページタイトルで遷移したことを確認する | 1 | goを実行し正常に実行されること | 1. bucky run -t e2e -d -D pc -c pc_e2e_1<br/>- 以下シナリオファイル内の処理 -<br/>2. goメソッド実行 (http://bucky.net)<br/>3. assert_titleメソッド実行 | goメソッドを実行後にページ遷移されていること<br/>（assert_titleメソッドの結果がOKであることを出力される文字列で判断） |
|  | Verifyが正常に実行できるか<br/>・シナリオコードに実装されたVerifyが実行できること<br/>・titleの確認ができること ※1種類のVerifyが確認できればOK | 2 | assert_titleを実行し、正常に動作すること | 1. bucky run -t e2e -d -D pc -c pc_e2e_1<br/>- 以下シナリオファイル内の処理 -<br/>2. goメソッド実行 (http://bucky.net)<br/>3. assert_titleメソッド実行 | assert_titleメソッド実行後にエラーが発生しないこと<br/>終了後のステータスが0であること |
|  |  | 3 | assert_titleを実行し、期待値と実際値が異なる場合に正常に検証NG時の動作をすること | 1. bucky run -t e2e -d -D pc -c pc_e2e_2<br/>- 以下シナリオファイル内の処理 -<br/>2. goメソッド実行 (http://bucky.net)<br/>3. assert_titleメソッド実行 | assert_titleメソッド実行後に検証NG判定されたことを表す文字列が表示されること<br/>終了後のステータスが1であること |
|  | 各デバイスのUAで正常に実行できるか | 4 | デバイスPCで実行し、正常にテストが実行されること | 1. bucky run -t e2e -d -D pc -c pc_e2e_3<br/>- 以下シナリオファイル内の処理 -<br/>2. goメソッド実行 (http://bucky.net)<br/>2. assert_textメソッド実行 | assert_textでUseragentを表す文字列をチェックした結果OKであることを出力される文字列で判断<br/><br/> |
|  |  | 5 | デバイスSPで実行し、正常にテストが実行されること | 1. bucky run -t e2e -d -D sp -c sp_e2e_1<br/>- 以下シナリオファイル内の処理 -<br/>2. goメソッド実行 (http://bucky.net)<br/>2. assert_textメソッド実行 | assert_textでUseragentを表す文字列をチェックした結果OKであることを出力される文字列で判断<br/><br/>Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1 |
|  |  | 6 | デバイスTabletで実行し、正常にテストが実行されること | 1. bucky run -t e2e -d -D tablet -c tablet_e2e_1<br/>- 以下シナリオファイル内の処理 -<br/>2. goメソッド実行 (http://bucky.net)<br/>2. assert_textメソッド実行 | assert_textでUseragentを表す文字列をチェックした結果OKであることを出力される文字列で判断<br/><br/>Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1 |
|  | setup/teardown_eachが正常に動作するか | 7 | setup_eachでgoを実行し正常に実行されること | 1. bucky run -t e2e -d -D pc -c setup_each_pc_e2e_1<br/>- 以下シナリオファイル内の処理 -<br/>2. setup内でgoメソッド実行 (http://bucky.net)<br/>3. testcase内でassert_titleメソッド実行 | goメソッドを実行後にページ遷移されていること<br/>（assert_titleメソッドの結果がOKであることを出力される文字列で判断） |
|  |  | 8 | teardown_eachでgoを実行し正常に実行されること | 1. bucky run -t e2e -d -D pc -c teardown_each_pc_e2e_1<br/>- 以下シナリオファイル内の処理 -<br/>2. teardown内でgoメソッド実行 (http://bucky.net)<br/>3. testcase内でassert_titleメソッド実行 | 例外が発生していないこと（終了後のステータスが0であること）<br/>→ 「0 failures, 0 errors」 と表示されること |
|  |  | 9 | setup_each/teardownを実行するケースを複数ケース続けて実行して正常に動作すること | 1. bucky run -t e2e -d -D pc -c setup_teardown_each_pc_e2e_1,setup_teardown_each_pc_e2e_2 <br/>- 以下シナリオファイル内の処理 -<br/>2. setup内でgoメソッド実行 (http://bucky.net)<br/>3. assert_titleメソッド実行<br/>4. testcase内でteardown内でgoメソッド実行 (http://bucky.net)<br/>5. setup内でgoメソッド実行 (http://bucky.net)<br/>6. testcase内でassert_titleメソッド実行<br/>7. teardown内でgoメソッド実行 (http://bucky.net) | 例外が発生していないこと（終了後のステータスが0であること）<br/>→ 「0 failures, 0 errors」 と表示されること |
| LinkStatusテスト実行機能 | 起点URLの検証が正しく実施できるか | 10 | linkstatusを実行し、起点URLが検証されること | 1. bucky run -t linkstatus -d -D pc -c pc_link_1<br/>2. http://bucky.net に対してhttpリクエストチェック実行 | 出力に http://bucky.net が含まれること |
|  | ページ内のリンクの検証が正しく実施できるか | 11 | linkstatusを実行し、起点ページ内のリンクが検証されること | 1. bucky run -t linkstatus -d -D pc -c pc_link_1<br/>2. http://bucky.net に対してhttpリクエストチェック実行<br/>3. http://bucky.net/test_page.html に対してLinkチェック実行 | 出力に http://bucky.net/test_page.htmlが含まれること |
|  | 各デバイス(PC/SP)のUAで正常に実行できるか | 12 | デバイスPCでlinkstatusを実行し、正常に動作すること | 1. bucky run -t linkstatus -d -D pc -c pc_link_1<br/>2. http://bucky.net に対してhttpリクエストチェック実行<br/>3. http://bucky.net/test_page.html に対してLinkチェック実行 | 終了後のステータスが0であること<br/>→ 「0 failures, 0 errors」 と表示されること |
|  |  | 13 | linkstatusNGテストを実行し、正常に動作すること | 1. bucky run -t linkstatus -d -D pc -c pc_link_2<br/>2. http://bucky-error.net に対してhttpリクエストチェック実行 | 終了後のステータスが1であること |
|  |  | 14 | デバイスSPでlinkstatusを実行し、正常に動作すること | 1. bucky run -t linkstatus -d -D sp -c sp_link_1<br/>2. http://bucky.net に対してhttpリクエストチェック実行<br/>3. http://bucky.net/test_page.html チェック実行 | 終了後のステータスが0であること<br/>→ 「0 failures, 0 errors」 と表示されること |
| テスト用のプロジェクト作成機能 | 下記の構造のディレクトリ、ファイルが生成されること<br/>(./template/new 以下の内容）<br/>.<br/>├── config<br/>│ ├── bucky_config.yml<br/>│ ├── e2e_config.yml<br/>│ ├── for_spec<br/>│ │ └── test.yml<br/>│ ├── linkstatus_config.yml<br/>│ └── test_db_config.yml<br/>├── services<br/>│ └── README.md<br/>└── system<br/>├── evidences<br/>│ ├── README.md<br/>│ └── screen_shots<br/>│ └── README.md<br/>└── logs<br/>└── README.md | 15 | newコマンド実行後に期待通りのファイル、ディレクトリが作成されていること | 1. bucky new test_project | 対象ディレクトリとファイルが存在していること |
| ページオブジェクト・パーツファイル作成機能 | 指定のサービス名、デバイスのディレクトリ以下に指定のページ名で.rbファイルと.ymlファイルが生成されること | 16 | make serviceコマンド実行後に期待通りのファイルが作成されていること | 1. (事前条件) bucky new test_project<br/>2. bucky make service test_service | 対象ディレクトリとファイルが存在していること |
|  |  | 17 | make pageコマンド実行後に期待通りのファイルが作成されていること | 1. (事前条件) bucky new test_project<br/>2. (事前条件) bucky make service test_service<br/>3. bucky make page test_page | 対象ディレクトリとファイルが存在していること |
| 未定義コマンド実行時の動き | 出力されるメッセージに Invalid command error. が含まれるか<br/>終了ステータスが 0 以外になるか | 18 | 未定義コマンド実行後にエラー終了すること | 1. bucky hoge fuga | 終了後のステータスが0以外であること |
| whenを使用しての実行時の動き | 出力されるメッセージに click が含まれるか<br/>例外が発生していないこと（終了後のステータスが0であること）<br/>→ 「0 failures, 0 errors」 と表示されること | 19 | 条件指定をしたテスト実行で不具合なくprocが実行されること | 1. STAGE=development bucky run -d -D -pc -c pc_e2e_4<br/>- 以下シナリオファイル内の処理 -<br/>2. goメソッド実行 (http://bucky.net)<br/>2. whenを使ったclickメソッド実行 | 例外が発生していないこと（終了後のステータスが0であること）<br/>→ 「0 failures, 0 errors」 と表示されること |
|  | 出力されるメッセージに click が含まれないこと（終了後のステータスが0であること） | 20 | 条件指定をしないテスト実行で該当のprocが実行されないこと | 1. bucky run -d -D -pc -c pc_e2e_4<br/>- 以下シナリオファイル内の処理 -<br/>2. goメソッド実行 (http://bucky.net)<br/>2. whenを使ったclickメソッドは実行されない | 例外が発生していないこと（終了後のステータスが0であること）<br/>→ 「click」 が表示されないこと |
|  |  | 21 | 違う条件を指定したテスト実行で該当のprocが実行されないこと | 1. STAGE=staging bucky run -d -D -pc -c pc_e2e_4<br/>- 以下シナリオファイル内の処理 -<br/>2. goメソッド実行 (http://bucky.net)<br/>2. whenを使ったclickメソッドは実行されない | 例外が発生していないこと（終了後のステータスが0であること）<br/>→ 「click」 が表示されないこと |
| 複数パーツ取得・選択機能 | Partファイルで複数取得、番号指定でエレメントが取得できること | 22 | CSSセレクタで指定したエレメントの２つ目の要素をクリックできること | 1. bucky run -t e2e -d -D pc -c pc_e2e_5<br/>- 以下シナリオファイル内の処理 -<br/>2. goメソッド実行 (http://bucky.net)<br/>2. assert_textメソッド実行 | 終了後のステータスが0であること<br/>→ 「0 failures, 0 errors」 と表示されること |
| PageObjectでのWebElement取得 | PageObjectファイルからパーツ（WebElement）が取得できること | 23 | PageObjectファイルからパーツ名でWebElementが取得できること | 1. bucky run -t e2e -d -D pc -c pc_e2e_6<br/>- 以下シナリオファイル内の処理 -<br/>2. goメソッド実行 (http://bucky.net)<br/>2. PageObjectメソッド click_single_element | 終了後のステータスが0であること<br/>→ 「0 failures, 0 errors」 と表示されること |
|  |  | 24 | PageObjectファイルからパーツ名[数字]でWebElementが取得できること | 1. bucky run -t e2e -d -D pc -c pc_e2e_7<br/>- 以下シナリオファイル内の処理 -<br/>2. goメソッド実行 (http://bucky.net)<br/>2. PageObjectメソッド click_multiple_element | 終了後のステータスが0であること<br/>→ 「0 failures, 0 errors」 と表示されること |
| VerificationでのWebElement取得 | Verificationファイルからパーツ（WebElement）が取得できること | 25 | Verificationファイルからパーツ名でWebElementが取得できること | 1. bucky run -t e2e -d -D pc -c pc_e2e_8<br/>- 以下シナリオファイル内の処理 -<br/>2. goメソッド実行 (http://bucky.net)<br/>2. Verificationメソッド click_single_element | 終了後のステータスが0であること<br/>→ 「0 failures, 0 errors」 と表示されること |
|  |  | 26 | Verificationファイルからパーツ名[数字]でWebElementが取得できること | 1. bucky run -t e2e -d -D pc -c pc_e2e_9<br/>- 以下シナリオファイル内の処理 -<br/>2. goメソッド実行 (http://bucky.net)<br/>2. Verificationメソッド click_multiple_element | 終了後のステータスが0であること<br/>→ 「0 failures, 0 errors」 と表示されること |