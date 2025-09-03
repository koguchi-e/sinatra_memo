# frozen_string_literal: true

require 'sinatra'
require 'ostruct'
require 'json'
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
    memos = Memo.all
    new_memo = Memo.new(Memo.next_id(memos), params[:title].to_s.strip, params[:body].to_s.strip)

    if new_memo.valid?
      memos << new_memo
      Memo.save_all(memos)
    end
    redirect '/memos'
  end

  before '/memos/:id*' do
    pass if params[:id] == 'new'
    @memos = Memo.all
    @memo = Memo.find(@memos, params[:id])
    halt erb(:not_found) unless @memo
  end

  get '/memos/:id' do
    erb :'memos/show'
  end

  get '/memos/:id/edit' do
    erb :'memos/edit'
  end

  patch '/memos/:id' do
    @memo.update(params[:title], params[:body])
    Memo.save_all(@memos)
    redirect "/memos/#{@memo.id}"
  end

  delete '/memos/:id' do
    @memos.delete(@memo)
    Memo.save_all(@memos)
    redirect '/memos'
  end
end
MemoApp.run! if __FILE__ == $PROGRAM_NAME
