#!/usr/bin/env ruby

require 'optparse'
require 'open3'
require 'net/http'
require 'json'
require 'socket'


options={}
  
$VERSION=1.0
$CONSUL_HOST=Socket.gethostbyname(Socket.gethostname.strip).first
#$CONSUL_HOST='192.168.59.104'
$CONSUL_API_PORT=8500
$CONSUL_RPC_PORT=8400
$CONSUL_CMD='/opt/consul/consul'
#$CONSUL_CMD='/usr/local/bin/consul'
$CONSUL_LEADER_URI='/v1/status/leader'
$CONSUL_PEERS_URI='/v1/status/peers'
$ERROR_EXIT_CODE=2

defaults={:debug => false, :consul_host => $CONSUL_HOST, :consul_port => $CONSUL_API_PORT }
  
OptionParser.new("Usage: #{$0} [options]") do |opts|
  opts.release = $VERSION
  opts.on("-d", "--debug", "Debug on") do |d|
    options[:debug] = true
  end 
  opts.on("-h", "--host CONSUL_HOST", "Consul host. Default: #{$CONSUL_HOST}") do |c|
    options[:consul_host] = c
  end
  opts.on("-p", "--port CONSUL_PORT", "Consul HTTP-API port. Default: #{$CONSUL_API_PORT}") do |p|
    options[:consul_port] = p
  end
  
end.parse!

config=defaults.merge!(options)

#  http://<consul-host>:8500/v1/status/peers
uri=URI.join("http://#{config[:consul_host]}:#{config[:consul_port]}", $CONSUL_PEERS_URI)

response=nil
begin
  response=Net::HTTP.get(uri)
rescue Exception => e
  puts "could not connect to consul uri #{uri}"
  exit $ERROR_EXIT_CODE
end

#peers='["10.47.80.102:8300","10.47.80.103:8300","10.47.80.101:8300"]'

# peers according to consul api
peers=JSON.parse(response)
puts "peers according to consul HTTP API (#{uri}): #{peers}" if config[:debug]
  
# members according to consul members command
output=[]
error=[]
begin
  Open3.popen3("#{$CONSUL_CMD} members --rpc-addr #{config[:consul_host]}:#{$CONSUL_RPC_PORT}") do |stdin, stdout, stderr, wait_thr|
    while line = stderr.gets
      if line.strip.length > 0
        error << line.strip
      end
    end
    
    if ! error.empty?
      raise StandardError, error.join("\n"), caller
    end
    
    puts "output of consul members command:" if config[:debug] 
    puts "#" * 75 if config[:debug] 
    while line = stdout.gets
     if line.strip.length > 0  
       puts line if config[:debug]
       output << line.strip
     end
    end 
    puts "#" * 75 if config[:debug]       
  end
rescue Exception => e
  puts "Error running consul members command: #{e}"
  exit $ERROR_EXIT_CODE
end

server_nodes=[]
output.each_with_index do |line,i|
  next if i == 0
  node, address, state, type, * = line.split
  if type =~ /server/ 
    puts "indentified server node: #{node}" if config[:debug]
    server_nodes << node 
  end
end

puts "HTTP-API peer count: #{peers.size}" if config[:debug]
puts "consul members server node count: #{server_nodes.size}" if config[:debug]

  
msg = lambda { |result|  "consul http-api peer count (#{peers.size}) " + result + " consul cli node count (#{server_nodes.size})"}
if peers.size == server_nodes.size
  puts msg.call("matches") 
  exit 0
else
  puts msg.call("does not match")
  puts "http-api peers: #{peers.join('|')}"
  puts "consul cli members: #{server_nodes.join('|')}"
  exit $ERROR_EXIT_CODE
end


