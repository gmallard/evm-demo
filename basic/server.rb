#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
$:.unshift File::dirname(__FILE__)
require 'parms'
#
# This is a one shot server:  it quits after the first and only client 
# connection completes.
#
module EchoServer

  def initialize *args
    super *args
    options = (Hash === args.last) ? args.pop : {}
    args.each do |narg|
      puts "next arg: #{narg}"
    end
    #
    puts "options hash:\t#{options.inspect}"
    # Define some class variables if needed.
    @@clp_01 = args[0]
    @@clp_02 = args[1]
    @@clp_03 = args[2]
    puts "-- initialize completes"
  end  

  def post_init
    puts "-- someone connected to the echo server!"
    showcl_parms()
  end

  def receive_data data
    rdata = data.split("\n")
    rdata.each do |line|
      puts "received <<< #{line}"
      # the echo part
      send_data ">>>you sent: #{line}\n"
      #
      if line =~ /quit/i
        close_connection if line =~ /quit/i
      end
    end
  end

  def unbind
    puts "-- someone disconnected from the echo server!"
    EventMachine::stop_event_loop()      
  end

  private
  #
  def showcl_parms()
    puts "clp_01: #{@@clp_01}"
    puts "clp_02: #{@@clp_02}"
    puts "clp_03: #{@@clp_03}"
    @@clp_03.sayhello()
  end
end

EventMachine::run {
  parma = "a string"  # String
  parmb = 1234        # Fixnum
  parmc = Parms.new   # Normal class
  opt_hash = {:a => 1, :b => "bv"}
  EventMachine::start_server("127.0.0.1", 8081, EchoServer, 
    parma, parmb, parmc, opt_hash)
  puts 'EM.run running echo server on 8081'
}
#
puts "Event loop complete."

