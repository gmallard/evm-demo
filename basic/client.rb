#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
#
class EchoClient < EventMachine::Connection

  def initialize *args
    super *args
    puts "#{self.class} client initialize runs"    
  end
  
  def post_init
    puts "#{self.class} client post_init runs"
  end

    def unbind
      puts "client a connection has terminated"
      EventMachine::stop_event_loop()      
    end
  
end
#
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
  # Connection sequence is done, unbind is called from the event loop
  # and we will quit.
}
#
puts "Event loop done"
