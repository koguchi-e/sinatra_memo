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
  end

  get '/memos' do
    erb :'memos/index'
  end

  get '/memos/new' do
    erb :'memos/new'
  end

  post '/memos' do
    new_memo = Memo.new(Memo.next_id(memos), params[:title].to_s.strip, params[:body].to_s.strip)

    if new_memo.valid?
      memos << new_memo
      save_memos_to_json
    end
    redirect '/memos'
  end

  before '/memos/:id*' do
    @memo = Memo.find(memos, params[:id])
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
    @memo.update(params[:title], params[:body])
    save_memos_to_json
    redirect "/memos/#{@memo.id}"
  end

  delete '/memos/:id' do
    halt erb(:not_found) unless @memo
    memos.delete(@memo)
    save_memos_to_json
    redirect '/memos'
  end

  not_found do
    erb :not_found
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
MemoApp.load_memos_from_json
MemoApp.run! if __FILE__ == $PROGRAM_NAME
