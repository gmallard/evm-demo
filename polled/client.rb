#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
#
# An example of a client that:
#
# 1. Initiates a connection to a server.
# 2. Periodically looks for work to send to the server, and if work is present sends it.
# 3. Periodically looks to see if a user initiated shutdown has been requested, and if so processes it.
#
class PollingClient < EventMachine::Connection
  # Initialize the connection
  def initialize *args
    super *args
    puts "#{self.class}/#{self} client initialize runs"    
  end

  #  Post initialize: EM::post_init() override
  def post_init
    puts "#{self.class}/#{self} client post_init runs"
  end

  # Receive: EM::receive_data(data) override
  def receive_data data
    puts "#{self} client receive_data:"
    rdata = data.split("\n")
    rdata.each do |line|
      puts "#{self} client received: #{line}"
      EventMachine::stop_event_loop if line =~ /quit/i
    end
  end

  # Unbind: EM::unbind() override
  def unbind
    puts "#{self} client a connection has terminated"
  end

  # Connect complete: EM::connection_completed() override
  def connection_completed()
    super()
    puts "#{self} connection_completed done!"
  end
  #
end
# shut_check(stopfile).
#
# Shutdown routine.  Called periodically, and checks for the existance of
# a user supplied stop indicator.  When found:
#
# * The stop indicator is removed.
# * The EM run loop is terminated.
#
def shut_check(stopfile)
  if File::exist?(stopfile)
    File::delete(stopfile)
    puts "#{self} Shutting down ......."
    EventMachine::stop_event_loop()
  end
end
# work_check(moreworkfile, connection)
#
# Periodically, look for more work to do.  When found:
#
# * Send work to the server
# * Remove work from input
#
def work_check(mfile, conn)
  # Do we have any work?
  if File::exist?(mfile)
    # Process work
    puts "#{self} Found workfile ......."
    open(mfile).each do |line|
      puts "#{self} #{line}"
      conn.send_data(line)
    end
    File::delete(mfile)
  else
    # Nothing to see here, move along.
    puts "#{self} waiting for work"
  end
end
#
# Miscellaneous timer intervals and file names
#
shut_check_secs = 10
work_check_secs = 5
work_file = "#{Dir::pwd}/messages.txt"
stop_file = "#{Dir::pwd}/stopfile.txt"
#
# The EM run / event loop.
#
EventMachine::run {
  puts "#{self} EM::run started"
  #
  puts "#{self} work file is: #{work_file}"
  puts "#{self} stop file is: #{stop_file}"
  #
  port = ENV['EM_PORT'] ? ENV['EM_PORT'] : 9091
  host = ENV['EM_HOST'] ? ENV['EM_HOST']  : "127.0.0.1"
  #
  conn = EventMachine::connect(host, port, PollingClient)
  puts "#{self} EM::run connected to #{host}:#{port}"
  #
  EventMachine::add_periodic_timer( work_check_secs ) {
    puts "#{self}  Work check starts, scheduled every #{work_check_secs} seconds" 
    work_check(work_file, conn)
  }
  #
  EventMachine::add_periodic_timer( shut_check_secs ) {
    puts "#{self}  Shutdown check starts, scheduled every #{shut_check_secs} seconds" 
    shut_check(stop_file)
  }
  #
  puts "#{self} EM::run block done"
}
#
puts "run loop complete"

