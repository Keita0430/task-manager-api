# README

1. プロジェクト概要 
    - タスク管理APIサーバー 
    - タスクのCRUD機能を提供
2. 技術スタック
    - Ruby: 3.4.1
    - Rails: 8.0.1
    - データベース: PostgreSQL（ローカル環境で直接実行）
3. 開発環境構築手順
   ```
   # リポジトリをクローン(SSH を使う場合)
   git clone git@github.com:Keita0430/task-manager-api.git
   cd task-manager-api

   # 必要なgemをインストール
   bundle install
   
   # PostgreSQL を起動していることを確認
   # (PostgreSQL が起動していない場合は `brew services start postgresql` などで起動)

   # データベースの設定
   rails db:create db:migrate db:seed

   # サーバーの起動
   rails s
   ```

4. APIエンドポイントの説明
    - タスク管理
    
      | メソッド      | エンドポイント |説明 |
      |-----------| ---- | ---- |
      | GET       | /api/v1/tasks | タスク一覧を取得 |
      | POST      | /api/v1/tasks | 新しいタスクを作成 |
      | PATCH/PUT | /api/v1/tasks/:id | 指定したタスクを更新 |
      | DELETE    | /api/v1/tasks/:id | 指定したタスクを削除 |
    - タスクの並び替え
    
      | メソッド      | エンドポイント |説明 |
      |-----------| ---- | ---- |
      | POST       | /api/v1/tasks/reorder | タスクの順番を変更 |
    - アーカイブ機能
    
      | メソッド      | エンドポイント |説明 |
      |-----------| ---- | ---- |
      | GET       | /api/v1/tasks/archived | アーカイブ済みタスクの一覧を取得 |
      | PATCH/PUT       | /api/v1/tasks/:task_id/archive | 指定したタスクをアーカイブ or 復元 |

5. テスト
    ```
    # テスト用データベースのセットアップ（初回のみ）
    rails db:test:prepare
    
    # テスト実行
    rspec
    ```
