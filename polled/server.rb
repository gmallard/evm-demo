#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
#
# A class style handler, subclasses EventMachine::Connection
#
class PolledServer  < EventMachine::Connection

  # Initialize
  def initialize *args
    super
    puts "#{self} initialize done"
  end  

  # -------------------------------

  #++
  # close_connection()
  #
  # Called only by user code, never by the event loop.
  #
  def close_connection()
    super()
    puts "#{self} close_connection done!"
  end

  #--
  # close_connection_after_writing()
  # comm_inactivity_timeout()
  # comm_inactivity_timeout=(value)

  #++
  # connection_completed()
  #
  # Called by the eventloop when remote TCP connection attempt completes 
  # successfully (according to the documentation).
  #
  def connection_completed()
    super()
    puts "#{self} connection_completed done!"
  end

  #--
  # detach()
  # error?()
  # get_peer_cert()
  # get_peername()
  # get_pid()
  # get_sock_opt(level,option)
  # get_sockname()
  # get_status()
  # notify_readable=(mode)
  # notify_readable?()
  # notify_writable=(mode)
  # notify_writable?()
  # pause()
  # paused?()
  # pending_connect_timeout()
  # pending_connect_timeout=(value)
  # post_init()

  #++
  # post_init()
  #
  # Called by the event loop after the connection is successfully established,
  # but before resumption of the network loop.
  #
  def post_init()
    puts "#{self} post_init done!"
  end

  #--
  # proxy_incoming_to(conn,bufsize=0)
  # proxy_target_unbound()

  #++
  # receive_data(data)
  #
  # Called only by the event loop hwenever data has been received on the 
  # network connection.  Never called by user code.
  #
  def receive_data data
    rdata = data.split("\n")
    rdata.each do |line|
      puts "#{self} received <<< #{line}"
      # the echo part
      send_data ">>>you sent: #{line}\n"
      close_connection if line =~ /quit/i
    end
  end

  #--
  # reconnect(server,port)
  # resume()

  #++
  # send_data(data)
  #
  # Called only by user code, never by the event loop.
  #
  def send_data(data)
    super(data)
    puts "#{self} send_data done: #{data.inspect}"
  end

  #--
  # send_datagram(data,recipient_address,recipient_port)
  # send_file_data(filename)
  # set_comm_inactivity_timeout(value)
  # set_pending_connect_timeout(value)
  # ssl_handshake_completed()
  # ssl_verify_peer(cert)
  # start_tls(args={})
  # stop_proxying()
  # stream_file_data(filename,

  #++
  # unbind()
  #
  # Called by the framework whenever a connection is closed, either by the 
  # client, the remote peer, or a network error.
  #
  # Clean up connection associations here.
  #
  def unbind
    puts "#{self} unbind done - connection is closed"
  end

end

EventMachine::run {
  EventMachine::start_server("127.0.0.1", 8081, PolledServer)
  puts 'running echo server on 8081'
}

