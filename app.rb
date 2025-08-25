# frozen_string_literal: true

require 'sinatra'
require 'ostruct'
require 'json'

class MemoApp < Sinatra::Base
  use Rack::MethodOverride
  helpers ERB::Util

  class << self
    attr_accessor :memos
  end

  helpers do
    def memos
      self.class.memos
    end

    def find_memo(id)
      memos.find { |m| m.id == id.to_i }
    end
  end

  get '/memos' do
    @memos = memos
    erb :'memos/index'
  end

  get '/memos/new' do
    @memos = memos
    erb :'memos/new'
  end

  class Memo
    attr_accessor :id, :title, :body

    def initialize(id, title, body)
      @id = id
      @title = title
      @body = body
    end
  end

  post '/memos' do
    @memos = memos
    title = params[:title].to_s.strip
    body = params[:body].to_s.strip

    unless title.empty?
      new_memo = Memo.new(@memos.size + 1, title, body)
      @memos << new_memo
      save_memos_to_json
    end
    redirect '/memos'
  end

  before '/memos/:id*' do
    @memo = find_memo(params[:id])
  end

  get '/memos/:id' do
    if @memo
      erb :'memos/show'
    else
      erb :not_found
    end
  end

  get '/memos/:id/edit' do
    if @memo
      erb :'memos/edit'
    else
      erb :not_found
    end
  end

  post '/memos/:id' do
    if @memo
      @memo.title = params[:title]
      @memo.body = params[:body]
      save_memos_to_json
      redirect "/memos/#{@memo.id}"
    else
      erb :not_found
    end
  end

  delete '/memos/:id' do
    if @memo
      memos.delete(@memo)
      save_memos_to_json
      redirect '/memos'
    else
      erb :not_found
    end
  end

  def save_memos_to_json
    memos_list = memos.map do |memo|
      {
        id: memo.id,
        title: memo.title,
        body: memo.body
      }
    end
    json_data = JSON.pretty_generate(memos_list)
    File.open('memos.json', 'w') do |file|
      file.write(json_data)
    end
  end

  get '/download_memos' do
    send_file 'memos.json', type: 'application/json', disposition: 'attachment'
  end

  not_found do
    erb :not_found
  end

  def self.load_memos_from_json
    if File.exist?('memos.json')
      memos = JSON.parse(File.read('memos.json'))
      self.memos = memos.map { |m| Memo.new(m['id'], m['title'], m['body']) }
    else
      self.memos = []
    end
  end
end
MemoApp.load_memos_from_json
MemoApp.run! if __FILE__ == $PROGRAM_NAME
