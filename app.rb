require 'sinatra'
require 'ostruct'
require 'json'

use Rack::MethodOverride

Memos = []

get '/' do
  @memos = Memos
  erb :index
end

get '/new' do
  @memo = Memos
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
    new_memo = Memo.new(Memos.size + 1 , title , body)
    Memos << new_memo
    save_memos_to_json
  end
  redirect '/'
end

get '/show/:id' do
  @memo = Memos.find { |m| m.id == params[:id].to_i }
  if @memo
    erb :show
  else
    "メモが見つかりませんでした"
  end
end

get '/edit/:id' do
  @memo = Memos.find { |m| m.id == params[:id].to_i }
  if @memo
    erb :edit
  else
    "メモが見つかりませんでした"
  end
end

delete '/delete/:id' do
  @memo = Memos.find { |m| m.id == params[:id].to_i }
  if @memo
    Memos.delete(@memo)
    redirect '/'
  else
    "メモが見つかりませんでした"
  end
end

post '/update/:id' do
  @memo = Memos.find { |m| m.id == params[:id].to_i }
  if @memo
    @memo.title = params[:title]
    @memo.body = params[:body]
    redirect "/show/#{@memo.id}"
  else
    "メモが見つかりませんでした"
  end
end

def save_memos_to_json
  memos = Memos.map do |memo|
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
