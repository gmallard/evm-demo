#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
#
class Polled < EventMachine::Connection

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
def shut_check(params={})
  stopfile = "#{Dir::pwd}/stopfile.txt"
  if File::exist?(stopfile)
    File::delete(stopfile)
    puts "Shutting down ......."
    EventMachine::stop_event_loop()
  end
end
#
def work_check(mfile, conn)
  if File::exist?(mfile)
    puts "Found workfile ......."
    open(mfile).each do |line|
      puts "#{line}"
      conn.send_data(line)
    end
    File::delete(mfile)
  else
    puts "waiting for work"
  end
end
#
shut_check_secs = 10
work_check_secs = 5
work_file = "messages.txt"
#
EventMachine::run {
  puts "#{self} EM::run started"

  conn = EventMachine::connect('127.0.0.1', 8081, Polled)
  puts "#{self} EM::run connected"
  #
  EventMachine::add_periodic_timer( shut_check_secs ) {
    puts "EM::run Shutdown check starts, scheduled every #{shut_check_secs} seconds" 
    shut_check(:a => 'aaa', :b => 'bbb')
  }
  #
  EventMachine::add_periodic_timer( work_check_secs ) {
    puts "EM::run Work check starts, scheduled every #{work_check_secs} seconds" 
    work_check("messages.txt", conn)
  }
  #
  puts "#{self} EM::run block done"
}
#

