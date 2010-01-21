#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
require 'logger'
#
class SSR01_Sender < EventMachine::Connection

  # initialize
  def initialize *args
    super *args
#    @@log = Logger::new(STDOUT)
    @@log = Logger::new("./temp_log.txt")
    @@log.level = Logger::DEBUG
    @@log.warn "#{self} initialize done"
  end
  
  # EM:Connection.post_init() override.
  def post_init
    @@log.warn "#{self} client post_init runs"
  end

  # send_data(data)
  #
  # Called only by user code, never by the event loop.
  #
  def send_data(data)
    super(data)
    @@log.warn "#{self} send_data done: #{data.inspect}"
  end

  # EM:Connection.unbind() override.
  def unbind
    @@log.warn "#{self} connection to server has terminated"
    EM.stop
  end
  
end

# The EM run/event loop.
EventMachine::run {
  puts "#{self} EM::run started"
  #
  port = ENV['EM_PORT'] ? ENV['EM_PORT'] : 8081
  host = ENV['EM_HOST'] ? ENV['EM_HOST']  : "127.0.0.1"
  #
  EventMachine::connect(host, port, SSR01_Sender) {|conn|
    puts "#{conn.class} EM::connect started"
    #
    data = ["line 1", "line 2", "line 3"]
    EventMachine::add_periodic_timer( 4 ) { 
      data.each do |line|
        puts "Sending: #{line}"
        conn.send_data("#{line}\n")
      end
    }

    #
  }
}
#
puts "Event loop done"

