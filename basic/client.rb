#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
#
class EchoClient < EventMachine::Connection

  # initialize
  def initialize *args
    super *args
    puts "#{self.class} client initialize runs"    
  end
  
  # EM:Connection.post_init() override.
  def post_init
    puts "#{self.class} client post_init runs"
  end

  # EM:Connection.unbind() override.  This is called because our server
  # will forcibly close the connection when we ask it to.
  def unbind
    puts "client a connection has terminated"
    EventMachine::stop_event_loop()      
  end
  
end

# The EM run/event loop.
EventMachine::run {
  puts "#{self.class} EM::run started"
  #
  EventMachine::connect('127.0.0.1', 8081, EchoClient) {|conn|
    puts "#{self.class} EM::connect self class"
    puts "#{conn.class} EM::connect started, connection class"
    #
    data = ["line 1", "line 2", "line 3"]
    data.each do |line|
      conn.send_data("#{line}\n")
    end
    #
    data = ["line 4", "line 5", "line 6", "quit line"]
    data.each do |line|
      conn.send_data("#{line}\n")
    end
    #
  }
  # Connection sequence is done, unbind is called becuase the network
  # connection has been closed by the server, and we will exit the run
  # run/event loop.
}
#
puts "Event loop done"

