#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
require 'logger'
#
# This server never ends.  Kill by ^C or 'kill'.
#
class SSR01_Server  < EventMachine::Connection

  @@data = nil

  # Initialize
  def initialize *args
    super
#    @@log = Logger::new(STDOUT)
    @@log = Logger::new("./temp_log.txt")
    @@log.level = Logger::DEBUG
    #
    @@data = @@data ? @@data : []
    #
    @@log.warn "#{self} initialize done"
    @@log.debug("Data: #{@@data}")
  end  

  # close_connection()
  #
  # Called only by user code, never by the event loop.
  #
  def close_connection()
    super()
    @@log.warn "#{self} close_connection done!"
  end

  # connection_completed()
  #
  # Called by the eventloop when remote TCP connection attempt completes 
  # successfully.
  #
  def connection_completed()
    super()
    @@log.warn "#{self} connection_completed done!"
  end

  # post_init()
  #
  # Called by the event loop after the connection is successfully established,
  # but before resumption of the network loop.
  #
  def post_init()
    @@log.warn "#{self} post_init done!"
  end

  # receive_data(data)
  #
  # Called only by the event loop hwenever data has been received on the 
  # network connection.  Never called by user code.
  #
  def receive_data(data)
    @@log.warn "#{self} receive_data ..."
    case
      when data == "GET\n"
        @@log.debug "#{self} received GET"
        send_backlog()
      else
        split_data = data.split("\n")
        @@data = @@data + split_data
        @@log.debug "#{self} \n<<<#{data}>>>"
    end
  end

  # send_data(data)
  #
  # Called only by user code, never by the event loop.
  #
  def send_data(data)
    super(data)
    @@log.warn "#{self} send_data .... "
    @@log.debug "#{self} \n<<<#{data}>>>"
  end

  # unbind()
  #
  # Called by the framework whenever a connection is closed, either by the 
  # client, the remote peer, or a network error.
  #
  # Clean up connection associations here.
  #
  def unbind()
    @@log.warn "#{self} unbind done - connection is closed"
  end

  # Called from within the event loop, by user added code.
  def send_backlog()
    @@log.debug "#{self} send_backlog"
    return if @@data.size == 0
    @@data.each do |message|
      send_data "#{message}\n"
    end
    @@data = []
  end
end
#
# The EM run loop.
#
EventMachine::run {
  port = ENV['EM_PORT'] ? ENV['EM_PORT'] : 9091
  host = ENV['EM_HOST'] ? ENV['EM_HOST']  : "127.0.0.1"
  #
  EventMachine::start_server(host, port, SSR01_Server)
  puts "#{self} - running server on #{host}:#{port}"
}

