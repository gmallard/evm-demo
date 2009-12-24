#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
$:.unshift File::dirname(__FILE__)
require 'parms'
#
module EchoServer

  def initialize *args
    super
    puts "-- initialize completes"
    args.each do |narg|
      puts "next arg: #{narg}"
    end
    # Try
    @@clp_01 = args[0]
    @@clp_02 = args[1]
    @@clp_03 = args[2]
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
      # close_connection if line =~ /quit/i
    end
  end

  def unbind
    puts "-- someone disconnected from the echo server!"
    showcl_parms()
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
  parma = "a string"
  parmb = 1234  # Fixnum
  parmc = Parms.new
  EventMachine::start_server("127.0.0.1", 8081, EchoServer, parma, parmb, parmc)
  puts 'running echo server on 8081'
}
