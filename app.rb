# frozen_string_literal: true

require 'sinatra'
require 'ostruct'
require 'json'
require_relative './models/memo'

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
    erb :'memos/index'
  end

  get '/memos/new' do
    erb :'memos/new'
  end

  post '/memos' do
    title = params[:title].to_s.strip
    body = params[:body].to_s.strip

    unless title.empty?
      new_memo = Memo.new(memos.size + 1, title, body)
      memos << new_memo
      save_memos_to_json
    end
    redirect '/memos'
  end

  before '/memos/:id*' do
    @memo = find_memo(params[:id])
  end

  get '/memos/:id' do
    halt erb(:not_found) unless @memo
    erb :'memos/show'
  end

  get '/memos/:id/edit' do
    halt erb(:not_found) unless @memo
    erb :'memos/edit'
  end

  patch '/memos/:id' do
    halt erb(:not_found) unless @memo
    @memo.title = params[:title]
    @memo.body = params[:body]
    save_memos_to_json
    redirect "/memos/#{@memo.id}"
  end

  delete '/memos/:id' do
    halt erb(:not_found) unless @memo
    memos.delete(@memo)
    save_memos_to_json
    redirect '/memos'
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
