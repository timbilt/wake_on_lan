# Wake On LAN Magic Packet Utility
# by Delano Cooper (Timbilt), 4/19/2014

require 'socket'
require_relative 'wol_packet'

class WakeOnLAN	
  DEFAULT_HOST = '<broadcast>'
  DEFAULT_PORT = 9

  Invalid_Number_Of_Arguments_Error = "Invalid number of arguments"

  def initialize *args
    @mac_host_port = setup_mac_host_port args
    @host, @port = @mac_host_port.last(2)
    @packet = WOLPacket.new @mac_host_port.first
  end

  def payload
    @packet.payload.pack("C*")
  end

  def wake
    begin
      @sock = UDPSocket.new
      set_socket_option
      send
    ensure
      @sock.close
    end
  end

  private

  def setup_mac_host_port args
    validate_args args
    args += [DEFAULT_HOST, DEFAULT_PORT] if args.size.eql? 1
    args += [DEFAULT_PORT] if args.size.eql? 2
    args
  end
  
  def validate_args args
    raise ArgumentError, Invalid_Number_Of_Arguments_Error unless (1..3).include? args.size
  end

  def send
    @sock.send payload, 0, @host, @port
  end

  def set_socket_option
    @sock.setsockopt Socket::SOL_SOCKET, Socket::SO_BROADCAST, true
  end
	
end