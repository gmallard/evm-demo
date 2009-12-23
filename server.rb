#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
#
 module EchoServer
   def post_init
     puts "-- someone connected to the echo server!"
   end

   def receive_data data
     rdata = data.split("\n")
     rdata.each do |line|
       puts "received <<< #{line}"
       # the echo part
       send_data ">>>you sent: #{line}\n"
       # close_connection if line =~ /quit/i
     end
   end

  def unbind
    puts "-- someone disconnected from the echo server!"
  end
 end

 EventMachine::run {
   EventMachine::start_server "127.0.0.1", 8081, EchoServer
   puts 'running echo server on 8081'
 }
