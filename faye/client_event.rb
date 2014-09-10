# http://blog.edweng.com/2012/06/02/faye-extensions-tracking-users-in-a-chat-room/

class ClientEvent
  def incoming(message, callback)
    
    if message['channel'] !~ %r{^/meta/}
      puts "[incoming] - message: #{message.inspect}"

      if message['data']['ext'] && message['data']['ext']['auth_token']
        message['ext'] = message['data']['ext']
        message['data'].delete('ext')
      end

      if message['ext']['auth_token'] != FAYE_TOKEN
        message['error'] = 'Invalid authentication token'
        puts "[ERROR] - Invalid authentication token"
      end
    end
    callback.call(message)
  end

  # IMPORTANT: clear out the auth token so it is not leaked to the client
  def outgoing(message, callback)
    if message['ext'] && message['ext']['auth_token']
      message['ext'] = {} 
    end
    callback.call(message)
  end

  def faye_client
    @faye_client ||= Faye::Client.new('http://localhost:9292/faye')
  end

  def faye_publish_online_status(channel, number_of_users)
    faye_client.publish(channel, {'object' => {'number_of_users' => number_of_users}, 'type' => 'online', 'ext' => {:auth_token => FAYE_TOKEN}})
  end
end