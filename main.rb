require 'json'

require 'sinatra'
require 'envlock'

require 'yaml'

schema = YAML.load_file('schema.yml')

get '/swagger.json' do
  schema.to_json
end

envlock = Envlock::Client.new('sherlock')


get '/lock' do
  locks = envlock.get_all_locked
  data = envlock.read(locks, false)

  data.to_json
end

get '/lock/:key' do
  result = envlock.read(params['key'])
  locks = result.select {|key, value| !value.nil?}

  if locks.length == 0
    [404]
  else
    result.to_json
  end
end

post '/lock/:key' do
  success = envlock.lock(params['key'], 'partkyle')
  unless success
    [400, {"msg" => "key already exists"}.to_json]
  end
end

delete '/lock/:key' do
  success, _count = envlock.unlock(params['key'], 'partkyle')
  unless success
    [404]
  end
end
