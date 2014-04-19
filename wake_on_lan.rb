# Wake On LAN Magic Packet Utility
# by Delano Cooper (Timbilt), 4/19/2014

require 'socket'
require_relative 'wol_packet'

class WakeOnLAN	
	DEFAULT_HOST = '<broadcast>'
	DEFAULT_PORT = 9
	
	Invalid_Number_Of_Arguments_Error = "Invalid number of arguments"
	
	def initialize *args
		@mac_host_port = args
		validate_mac_host_port
		
		@host, @port = @mac_host_port.last(2)
		@packet = WOLPacket.new @mac_host_port.first
	end
	
	def payload
		@packet.payload.pack("C*")
	end
	
	def wake
		connect
		send
	end
	
	private
	
	def validate_mac_host_port
		raise ArgumentError, Invalid_Number_Of_Arguments_Error unless (1..3).include? @mac_host_port.size
		@mac_host_port += [DEFAULT_HOST, DEFAULT_PORT] if @mac_host_port.size.eql? 1
		@mac_host_port += [DEFAULT_PORT] if @mac_host_port.size.eql? 2
	end
	
	def connect
		(@sock = UDPSocket.new).connect @host, @port
		setsockopt if @host == DEFAULT_HOST
	end
	
	def send
		begin
			return @sock.send payload, 0
		ensure
			@sock.close
		end
	end
	
	def setsockopt
		@sock.setsockopt Socket::SOL_SOCKET, Socket::SO_BROADCAST, true
	end
	
end