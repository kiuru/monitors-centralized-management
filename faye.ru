# start rack: rackup faye.ru -s thin -E production
#
# Launch faye inside thin. Fix long polling issues: https://github.com/faye/faye/issues/192
# thin -p 9292 -t 60 -R faye.ru start

require 'faye'
require 'net/http'
require 'json'

require File.expand_path('../config/initializers/faye_token.rb', __FILE__)
load 'faye/client_event.rb'

# Websocket header missing fix
Faye::WebSocket.load_adapter('thin')

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(ClientEvent.new)
client_event = ClientEvent.new


faye_server.on(:handshake) do |client_id|
  puts "[handshake] - client: #{client_id}"
end

connections = {}
#number_of_users = 0
faye_server.on(:subscribe) do |client_id, channel|
  if connections[channel.to_sym].nil?
    connections[channel.to_sym] = 0
  end

  connections[channel.to_sym] += 1
  client_event.faye_publish_online_status(channel, connections[channel.to_sym])
  puts "[subscribe] - client: #{client_id}, channel: #{channel}"
end

faye_server.on(:unsubscribe) do |client_id, channel|
  connections[channel.to_sym] -= 1
  client_event.faye_publish_online_status(channel, connections[channel.to_sym])
  puts "[unsubscribe] - client: #{client_id}, channel: #{channel}"
end

faye_server.on(:disconnect) do |client_id|
  puts "[disconnect] - client: #{client_id}"
end

faye_server.on(:publish) do |client_id, channel, data|
  puts "[publish] - client: #{client_id}, channel: #{channel}, data: #{data}"
end

run faye_server