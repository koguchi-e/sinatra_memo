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

  def update(title, body)
    @title = title
    @body = body
    conn = db_connection
    conn.exec_params(
      'UPDATE memos SET title = $1, body = $2 WHERE id = $3',
      [params[:title], params[:body], params[:id]]
    )
  end

  def self.find(id)
    conn = db_connection
    sql = 'SELECT id, title, body FROM memos WHERE id = $1'
    result = conn.exec_params(sql, [id])
    result.first
  end

  def self.create(title, body)
    conn = db_connection
    sql = 'INSERT INTO memos (title, body) VALUES ($1, $2)'
    conn.exec_params(sql, [title, body])
  end

  def self.all
    conn = db_connection
    sql = 'SELECT id, title, body FROM memos ORDER BY id'
    result = conn.exec(sql)
    result.map { |row| row }
  end

  def self.delete(id)
    conn = db_connection
    sql = 'DELETE FROM memos WHERE id = $1'
    conn.exec_params(sql, [id])
  end
end
