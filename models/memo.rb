# frozen_string_literal: true

class Memo
  attr_reader :id, :title, :body

  def initialize(id, title, body)
    @id = id
    @title = title
    @body = body
  end

  def to_h
    { id: id, title: title, body: body }
  end

  def valid?
    !title.to_s.strip.empty?
  end

  def update(title, body)
    @title = title
    @body = body
  end

  def self.next_id(memos)
    memos.map(&:id).max.to_i + 1
  end

  def self.db_connection
    PG.connect(dbname: 'memo_app')
  end

  def self.find(memos, id)
    conn = db_connection
    sql = "SELECT id, title, body FROM memos WHERE id = $1"
    result = conn.exec_params(sql, [id])
    conn.close
    result.first
  end

  def self.save_all(title, body, id)
    conn = db_connection
    sql = "INSERT INTO memos (title, body) VALUES ($1, $2)"
    conn.exec_params(sql, [title, body])
    conn.close
  end

  def self.all
    conn = db_connection
    sql = "SELECT id, title, body FROM memos ORDER BY id"
    result = conn.exec(sql)
    conn.close
    result.map { |row| row }
  end

  def self.delete(id)
    conn = db_connection
    sql = "DELETE FROM memos WHERE id = $1"
    conn.exec_params(sql, [id])
    conn.close
  end
end
