require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
require 'logger'
require 'daemons/daemonize'
#
# This demo behaves *very* oddly.
#
# At first the problem appeared to be some bizarre interaction between:
#
# a) Ruby trunk level, with:
# b) Eventmachine gem (1.0.0), and:
# c) Daemons gem (1.1.9)
#
# Depending on Ruby level two behaviors were observed:
#
# a) The EM disconnect sequence is triggered immediately after client connect.
# b) The EM connect sequence is never seen (server hang).
#
# After some experimentation, the daemons gem level appears to be the 
# triggering factor.
#
# If the call to 'Daemonize.daemonize' below is commented out, all is well.
# This seems to rule out Ruby level or EM as a direct casue.
#
# Further experimentation shows:
#
# * if daemons 1.1.9 is uninstalled, and 1.1.6 is installed, all is well.
#
# Further investigation shows that this behavior was introduced by daemons
# SVN revision 65.
#
class EchoServer < EventMachine::Connection

  def initialize *args
    super *args
		@log = Logger::new(STDOUT)
		@log.level = Logger::DEBUG
		Daemonize.daemonize("/tmp/log.txt") # !!!!! HERE !!!!!
    @log.debug "-- initialize completes!"
  end  

  def post_init
    @log.debug "-- post initialize completes!"
  end

  def receive_data data
    rdata = data.split("\n")
    rdata.each do |line|
      @log.debug "received <<< #{line}"
      send_data ">>>you sent: #{line}\n"
      if line =~ /quit/i
        close_connection
      end
    end
  end

  def send_data(data)
    super(data)
    @log.debug "send_data done: #{data.inspect}"
  end

  def unbind
    @log.debug "-- someone disconnected from the echo server!"
    EventMachine::stop_event_loop()      
  end

end

EventMachine::run {

  EventMachine::start_server("127.0.0.1", 9091, EchoServer)
  puts 'EM.run running echo server on 9091'
}

puts "Event loop complete."

