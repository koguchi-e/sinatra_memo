# frozen_string_literal: true

class Memo
  attr_reader :id, :title, :body

  def initialize(id, title, body)
    @id = id
    @title = title
    @body = body
  end

  def self.with_connection
    conn = MemoApp.instance_variable_get(:@db_connection)
    yield(conn)
  end

  def self.create(conn, title, body)
    sql = 'INSERT INTO memos (title, body) VALUES ($1, $2)'
    conn.exec_params(sql, [title, body])
  end

  def self.all(conn)
    sql = 'SELECT id, title, body FROM memos ORDER BY id'
    conn.exec(sql).map { |row| new(row['id'], row['title'], row['body']) }
  end

  def self.find(conn, id)
    row = conn.exec_params('SELECT id, title, body FROM memos WHERE id = $1', [id]).first
    row && new(row['id'], row['title'], row['body'])
  end

  def update(conn, title, body)
    @title = title
    @body = body
    conn.exec_params(
      'UPDATE memos SET title = $1, body = $2 WHERE id = $3',
      [title, body, id]
    )
  end

  def self.delete(conn, id)
    sql = 'DELETE FROM memos WHERE id = $1'
    conn.exec_params(sql, [id])
  end
end
