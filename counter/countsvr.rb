require 'rubygems'
require 'eventmachine'

module LineCounter
 MaxLinesPerConnection = 10

 def post_init
   puts "Received a new connection"
   @data_received = ""
   @line_count = 0
 end

 def receive_data data
   @data_received << data
   while @data_received.slice!( /^[^\n]*[\n]/m )
     @line_count += 1
     send_data "received #{@line_count} lines so far\r\n"
     @line_count == MaxLinesPerConnection and close_connection_after_writing
   end
 end
end

EventMachine::run {
 host,port = "127.0.0.1", 8081
 EventMachine::start_server host, port, LineCounter
 puts "Now accepting connections on address #{host}, port #{port}..."
 EventMachine::add_periodic_timer( 10 ) { $stderr.write "*" }
}

