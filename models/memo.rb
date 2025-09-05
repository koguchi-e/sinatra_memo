# frozen_string_literal: true

class Memo
  attr_reader :id, :title, :body

  def initialize(id, title, body)
    @id = id
    @title = title
    @body = body
  end

  def self.db_connection
    PG.connect(dbname: 'memo_app')
  end

  def self.with_connection
    conn = db_connection
    yield(conn)
  end

  def self.create(title, body)
    with_connection do |conn|
      sql = 'INSERT INTO memos (title, body) VALUES ($1, $2)'
      conn.exec_params(sql, [title, body])
    end
  end

  def self.all
    with_connection do |conn|
      sql = 'SELECT id, title, body FROM memos ORDER BY id'
      conn.exec(sql).map { |row| new(row["id"], row["title"], row["body"]) }
    end
  end

  def self.find(id)
    with_connection do |conn|
      row = conn.exec_params('SELECT id, title, body FROM memos WHERE id = $1', [id]).first
      row && new(row["id"], row["title"], row["body"])
    end
  end

  def update(title, body)
    @title = title
    @body = body
    self.class.with_connection do |conn|
      conn.exec_params(
        'UPDATE memos SET title = $1, body = $2 WHERE id = $3',
        [title, body, id]
      )
    end
  end

  def self.delete(id)
    with_connection do |conn|
      sql = 'DELETE FROM memos WHERE id = $1'
      conn.exec_params(sql, [id])
    end
  end
end
