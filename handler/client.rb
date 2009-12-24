#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
#
class Echo < EventMachine::Connection

  def initialize *args
    super *args
    puts "#{self.class}/#{self} client initialize runs"    
  end
  
  def post_init
    puts "#{self.class}/#{self} client post_init runs"
  end

   def receive_data data
     puts "#{self} client receive_data:"
     rdata = data.split("\n")
     rdata.each do |line|
       puts "#{self} client received: #{line}"
       EventMachine::stop_event_loop if line =~ /quit/i
     end
   end

   def unbind
     puts "#{self} client a connection has terminated"
   end
  
end
#
EventMachine::run {
  puts "#{self.class} EM::run started"
  EventMachine::connect('127.0.0.1', 8081, Echo) {|conn|
    puts "#{self.class} EM::connect self class"
    puts "#{conn.class} EM::connect started, connection class"
    #
    data = ["line 1", "line 2", "line 3"]
    data.each do |line|
      conn.send_data("#{line}\n")
    end
    #
  }
}
#
puts "Event loop done"
