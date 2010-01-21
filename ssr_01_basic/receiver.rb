#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
require 'logger'
#
class SSR01_Receiver < EventMachine::Connection

  # initialize
  def initialize *args
    super *args
#    @@log = Logger::new(STDOUT)
    @@log = Logger::new("./temp_log.txt")
    @@log.level = Logger::DEBUG
    @@log.warn "#{self} initialize done"
    #
    @received = []
  end
  
  # EM:Connection.post_init() override.
  def post_init
    @@log.warn "#{self} client post_init runs"
  end


  # receive_data(data)
  #
  # Called only by the event loop hwenever data has been received on the 
  # network connection.  Never called by user code.
  #
  def receive_data(data)
    split_data = data.split("\n")
    @received = @received + split_data
    @@log.warn "#{self} receive_data ..."
    @@log.debug "#{self} \n<<<#{data}>>>"
  end

  # send_data(data)
  #
  # Called only by user code, never by the event loop.
  #
  def send_data(data)
    super(data)
    @@log.warn "#{self} send_data done: #{data.inspect}"
  end

  # EM:Connection.unbind() override.
  def unbind
    @@log.warn "#{self} connection to server has terminated"
    EM.stop
  end

  def get_reply()
    ret = @received
    @received = []
    ret
  end
  
end

# The EM run/event loop.
EventMachine::run {
  puts "#{self} EM::run started"
  #
  port = ENV['EM_PORT'] ? ENV['EM_PORT'] : 8081
  host = ENV['EM_HOST'] ? ENV['EM_HOST']  : "127.0.0.1"
  #
  EventMachine::connect(host, port, SSR01_Receiver) {|conn|
    puts "#{conn.class} EM::connect started"
    #
    reply = nil
    #
    EventMachine::add_periodic_timer( 2 ) { 
      conn.send_data("GET\n")
      reply = conn.get_reply()
      puts "Timer loop:"
      p reply
    }
  }
}
#
puts "Event loop done"

