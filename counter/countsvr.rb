require 'rubygems'
require 'eventmachine'
#
# Another example from the EventMachine documentation.
#
# Use the 'runtelnet.sh' script to connect to this server from multiple
# terminal sessions for this example.
#
# Kill this sever by ^C or kill.
#
module LineCounter
  #
  MaxLinesPerConnection = 10

  # EM::Connection.post_init override
  def post_init
    puts "\n#{self.inspect} Received a new connection"
    @data_received = ""
    @line_count = 0
  end

  # EM::Connection.receive_data override
  def receive_data data
    @data_received << data
    while @data_received.slice!( /^[^\n]*[\n]/m )
      @line_count += 1
      data_out = "#{self.inspect} received #{@line_count} lines so far\r\n"
      send_data data_out
      puts data_out
      # Force connection close after 10 lines received.
      @line_count == MaxLinesPerConnection and close_connection_after_writing
    end
  end
end

#
# EM Run/Event loop
#
EventMachine::run {
  host,port = "127.0.0.1", 8081
  # No additional initialize parameters are used here.
  EventMachine::start_server host, port, LineCounter
  puts "Now accepting connections on address #{host}, port #{port}..."
  # Server heartbeat
  EventMachine::add_periodic_timer( 10 ) { $stderr.write "*" }
}

