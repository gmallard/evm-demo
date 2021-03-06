#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
#
# A class style protocol handler, subclasses EventMachine::Connection.
#
# This is another one shot server, and quite similar to the example in the
# 'basic' subdirectory of this project.
#
# The primary purpose is to document the methods available from the 
# EM::connection class.  This documentation is available by reviewing the 
# code.
#
class HandlerServer  < EventMachine::Connection

  # Initialize
  def initialize *args
    super
    puts "#{self} initialize done"
  end  

  # -------------------------------

  # :startdoc:

  # close_connection().
  #
  # Called only by user code, never by the event loop.
  #
  def close_connection()
    super()
    puts "#{self} close_connection done!"
  end

  # :stopdoc:

  # close_connection_after_writing()
  # comm_inactivity_timeout()
  # comm_inactivity_timeout=(value)

  # :startdoc:

  # connection_completed().
  #
  # Called by the eventloop when remote TCP connection attempt completes 
  # successfully.
  #

  # :stopdoc:

  # I do not see this being called.  Why?  The documentation says it is for
  # network diagnostic purposes, and to use post_init() to complete 
  # connection processing. However, it seems like it _should_ be called.
  #
  # It finally ocurred to me:  this method is called when the EM run loop
  # issues:
  #
  # * EM:connect
  #
  # but _not_ when the run loop issues:
  #
  # * EM:start_server
  #
  def connection_completed()
    super()
    puts "#{self} connection_completed done!"
  end

  # :stopdoc:

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

  # :startdoc:

  # post_init()
  #
  # Called by the event loop after the connection is successfully established,
  # but before resumption of the network loop.
  #
  def post_init()
    puts "#{self} post_init done!"
  end

  # :stopdoc:

  # proxy_incoming_to(conn,bufsize=0)
  # proxy_target_unbound()

  # :startdoc:

  # receive_data(data).
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
      # Close the connection when the client tells us to.
      close_connection if line =~ /quit/i
    end
  end

  # :stopdoc:

  # reconnect(server,port)
  # resume()

  # :startdoc:

  # send_data(data).
  #
  # Called only by user code, never by the event loop.
  #
  def send_data(data)
    super(data)
    puts "#{self} send_data done: #{data.inspect}"
  end

  # :stopdoc:

  # send_datagram(data,recipient_address,recipient_port)
  # send_file_data(filename)
  # set_comm_inactivity_timeout(value)
  # set_pending_connect_timeout(value)
  # ssl_handshake_completed()
  # ssl_verify_peer(cert)
  # start_tls(args={})
  # stop_proxying()
  # stream_file_data(filename,

  # :startdoc:

  # unbind().
  #
  # Called by the framework whenever a connection is closed, either by the 
  # client, the remote peer, or a network error.
  #
  # Clean up connection associations here.
  #
  def unbind
    puts "#{self} unbind done - connection is closed"
    EventMachine::stop_event_loop()
  end

end
#
# The EM run / event loop.
#
EventMachine::run {
  EventMachine::start_server("127.0.0.1", 9091, HandlerServer)
  puts 'running echo server on 9091'
}

