# frozen_string_literal: true

class Memo
  attr_accessor :id, :title, :body

  def initialize(id, title, body)
    @id = id
    @title = title
    @body = body
  end

  def to_h
    { id: id, title: title, body: body }
  end

  def self.from_h(hash)
    new(hash['id'] || hash[:id], hash['title'] || hash[:title], hash['body'] || hash[:body])
  end

  def valid?
    !title.to_s.strip.empty?
  end

  def update(title, body)
    self.title = title
    self.body = body
  end

  def self.find(memos, id)
    memos.find { |m| m.id.to_i == id.to_i }
  end

  def self.next_id(memos)
    memos.map(&:id).max.to_i + 1
  end
end
