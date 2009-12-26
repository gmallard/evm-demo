require 'rubygems'
require 'eventmachine'
#
# Another example from the EventMachine documentation.
#
# Use the 'runtelnet.sh' script to connect to this server from multiple
# terminal sessions for this example.
#
# Kill this sever by ^C.
#
module LineCounter
  #
  MaxLinesPerConnection = 10
  #
  def post_init
    puts "\nReceived a new connection"
    @data_received = ""
    @line_count = 0
  end
  #
  def receive_data data
    @data_received << data
    while @data_received.slice!( /^[^\n]*[\n]/m )
      @line_count += 1
      send_data "received #{@line_count} lines so far\r\n"
      @line_count == MaxLinesPerConnection and close_connection_after_writing
    end
  end
end
#
# EM Runloop
#
EventMachine::run {
  host,port = "127.0.0.1", 8081
  EventMachine::start_server host, port, LineCounter
  puts "Now accepting connections on address #{host}, port #{port}..."
  # Server heartbeat
  EventMachine::add_periodic_timer( 10 ) { $stderr.write "*" }
}

