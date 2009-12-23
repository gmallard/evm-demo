#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
#
module Echo

  def post_init
    puts "client post_init runs"
    data = ["line 1", "line 2", "line 3", "quit line"]
    data.each do |line|
      send_data "#{line}\n"
    end
  end

   def receive_data data
     puts "client receive_data:"
     rdata = data.split("\n")
     rdata.each do |line|
       puts "client received: #{line}"
       EventMachine::stop_event_loop if line =~ /quit/i
     end
   end

   def unbind
     puts "client a connection has terminated"
   end
  
end
#
EventMachine::run {
  EventMachine::connect '127.0.0.1', 8081, Echo
  puts "EM::run started"
}
#
puts "Event loop done"
