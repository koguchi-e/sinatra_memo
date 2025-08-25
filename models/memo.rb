# frozen_string_literal: true

class Memo
  attr_accessor :id, :title, :body

  def initialize(id, title, body)
    @id = id
    @title = title
    @body = body
  end
end
