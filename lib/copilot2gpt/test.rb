require 'sinatra'
require 'faraday'

get '/test' do
  stream do |s|
    200.times do |i|
      s << "data #{i}\n"
      sleep 0.1
    end
  end
end