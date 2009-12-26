#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
#
class HandlerClient < EventMachine::Connection
  #
  # Initialize the client connection.
  #
  def initialize *args
    super *args
    puts "#{self} client initialize runs"    
  end
  #
  # Connect is done.
  #
  def post_init
    puts "#{self} client post_init runs"
  end
  #
  # Connection terminated.
  #
  def unbind
    puts "#{self} client a connection has terminated"
    EventMachine::stop_event_loop()
  end
#
end # of class HandlerClient
#
# The EM run loop.
#
EventMachine::run {
  puts "#{self} EM::run started"
  # Connect sequence.  All processing occurs here.
  EventMachine::connect('127.0.0.1', 8081, HandlerClient) {|conn|
    puts "#{conn} EM::connect self class"
    puts "#{conn} EM::connect started, connection class"
    #
    data = ["line 1", "line 2", "line 3", "do quit please"]
    data.each do |line|
      conn.send_data("#{line}\n")
      puts "#{conn} sent #{line}"
    end
    #
  }
  # The connect sequence will end because the server terminated the 
  # connection at the client's request.
  # This causes the unbind method is driven in this client, and when 
  # EM::stop_event_loop() is called the run loop will terminate.
}
#
puts "Event loop done"

