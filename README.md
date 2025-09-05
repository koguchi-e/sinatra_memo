## 該当プラクティス
[プラクティス Sinatra を使ってWebアプリケーションの基本を理解する \| FBC](https://bootcamp.fjord.jp/practices/157)

## クローン～起動手順
### 前提条件
- Ruby（3.x以上推奨）がインストールされていること
- Bundlerがインストールされていること
```bash
gem install bundler
```

### リポジトリをクローン
```bash
git clone https://github.com/koguchi-e/sinatra_memo.git
cd sinatra_memo
```

### ブランチの切り替え
```bash
git checkout -b memo_practice origin/DB-practice
```

### 必要なgemのインストール
```bash
bundle install
```

## データベースの作成
### PostgreSQL のインストール
PostgreSQL がインストールされているか確認するため、以下コマンドでバージョンを確認。
```bash
psql --version
```

何も出てこない場合は、以下コマンドでインストール。
```bash
brew update
brew install postgresql
```

サービスを起動する。
```bash
brew services start postgresql
```

### データベースの作成
自分のユーザー名と同じデータベースを作成。
```bash
createdb $USER
```

PostgreSQL に接続。
```bash
psql
```

`memo_app`の名前でデータベースを作成。
```sql
createdb memo_app
```

`memos`の名前でテーブルを作成。
```sql
CREATE TABLE memos (
  id SERIAL PRIMARY KEY,
  title TEXT,
  body TEXT
);
```

アプリケーションを起動。
```bash
bundle exec rackup
```

## 使い方
### メモの新規追加
トップ画面の「新規登録」をクリック。<br>
![alt text](public/images/top.png)

入力画面でタイトル・本文を入力し、「登録」をクリック。<br>
![alt text](public/images/new.png)

登録完了後、一覧画面に移動。追加されたメモを確認できます。<br>
![alt text](public/images/top2.png)


### 修正・削除
一覧から編集したいメモ名をクリック。
詳細画面で「編集」や「削除」ができます。<br>
![alt text](public/images/show.png)

## 補足
`public/images/` 配下の画像は説明用です。動作自体には不要です。
