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

  def self.load_memos_from_json
    if File.exist?('memos.json')
      json = JSON.parse(File.read('memos.json'))
      self.memos = json.map { |h| Memo.new(*h.values) }
    else
      self.memos = []
    end
  end

  def save_memos_to_json
    json_data = JSON.pretty_generate(memos.map(&:to_h))
    File.open('memos.json', 'w') do |file|
      file.write(json_data)
    end
  end
end
