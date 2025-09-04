# frozen_string_literal: true

require 'sinatra'
require 'ostruct'
require 'pg'
require_relative './models/memo'

class MemoApp < Sinatra::Base
  use Rack::MethodOverride
  helpers ERB::Util

  get '/' do
    redirect '/memos'
  end

  get '/memos' do
    @memos = Memo.all
    erb :'memos/index'
  end

  get '/memos/new' do
    erb :'memos/new'
  end

  post '/memos' do
    Memo.save_all(params[:title], params[:body])
    redirect '/memos'
  end

  before '/memos/:id*' do
    pass if params[:id] == 'new'
    @memos = Memo.all
    @memo = Memo.find(params[:id])
    halt erb(:not_found) unless @memo
  end

  get '/memos/:id' do
    erb :'memos/show'
  end

  get '/memos/:id/edit' do
    erb :'memos/edit'
  end

  patch '/memos/:id' do
    conn = Memo.db_connection
    conn.exec_params(
      'UPDATE memos SET title = $1, body = $2 WHERE id = $3',
      [params[:title], params[:body], params[:id]]
    )
    conn.close

    redirect "/memos/#{params[:id]}"
  end

  delete '/memos/:id' do
    Memo.delete(params[:id])
    redirect '/memos'
  end
end
MemoApp.run! if __FILE__ == $PROGRAM_NAME
