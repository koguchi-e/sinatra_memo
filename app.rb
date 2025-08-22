# frozen_string_literal: true

require 'sinatra'
require 'ostruct'
require 'json'

use Rack::MethodOverride
helpers ERB::Util

MEMOS = []

get '/' do
  @memos = MEMOS
  erb :index
end

get '/new' do
  @memo = MEMOS
  erb :new
end

class Memo
  attr_accessor :id, :title, :body

  def initialize(id, title, body)
    @id = id
    @title = title
    @body = body
  end
end

post '/new' do
  title = params[:title].to_s.strip
  body = params[:body].to_s.strip

  unless title.empty?
    new_memo = Memo.new(MEMOS.size + 1, title, body)
    MEMOS << new_memo
    save_memos_to_json
  end
  redirect '/'
end

get '/show/:id' do
  @memo = MEMOS.find { |m| m.id == params[:id].to_i }
  if @memo
    erb :show
  else
    erb :not_found
  end
end

get '/edit/:id' do
  @memo = MEMOS.find { |m| m.id == params[:id].to_i }
  if @memo
    erb :edit
  else
    erb :not_found
  end
end

delete '/delete/:id' do
  @memo = MEMOS.find { |m| m.id == params[:id].to_i }
  if @memo
    MEMOS.delete(@memo)
    redirect '/'
  else
    erb :not_found
  end
end

post '/update/:id' do
  @memo = MEMOS.find { |m| m.id == params[:id].to_i }
  if @memo
    @memo.title = params[:title]
    @memo.body = params[:body]
    redirect "/show/#{@memo.id}"
  else
    erb :not_found
  end
end

def save_memos_to_json
  memos = MEMOS.map do |memo|
    {
      id: memo.id,
      title: memo.title,
      body: memo.body
    }
  end
  json_data = JSON.pretty_generate(memos)
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
