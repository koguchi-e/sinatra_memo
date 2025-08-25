# frozen_string_literal: true

require 'sinatra'
require 'ostruct'
require 'json'

use Rack::MethodOverride
helpers ERB::Util

class MemoApp < Sinatra::Base
  helpers ERB::Util

  @memos = []

  class << self
    attr_accessor :memos
  end

  get '/' do
    @memos = self.class.memos
    erb :index
  end

  get '/new' do
    @memos = self.class.memos
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
    @memos = self.class.memos
    title = params[:title].to_s.strip
    body = params[:body].to_s.strip

    unless title.empty?
      new_memo = Memo.new(@memos.size + 1, title, body)
      @memos << new_memo
      save_memos_to_json
    end
    redirect '/'
  end

  get '/show/:id' do
    @memos = self.class.memos
    @memo = @memos.find { |m| m.id == params[:id].to_i }
    if @memo
      erb :show
    else
      erb :not_found
    end
  end

  get '/edit/:id' do
    @memos = self.class.memos
    @memo = @memos.find { |m| m.id == params[:id].to_i }
    if @memo
      erb :edit
    else
      erb :not_found
    end
  end

  delete '/delete/:id' do
    @memos = self.class.memos
    @memo = @memos.find { |m| m.id == params[:id].to_i }
    if @memo
      @memos.delete(@memo)
      redirect '/'
    else
      erb :not_found
    end
  end

  post '/update/:id' do
    @memos = self.class.memos
    @memo = @memos.find { |m| m.id == params[:id].to_i }
    if @memo
      @memo.title = params[:title]
      @memo.body = params[:body]
      redirect "/show/#{@memo.id}"
    else
      erb :not_found
    end
  end

  def save_memos_to_json
    @memos = self.class.memos
    memos = @memos.map do |memo|
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
end
MemoApp.run! if __FILE__ == $PROGRAM_NAME
