#!/usr/bin/ruby -w

# Wake On LAN Magic Packet Utility
# by Delano Cooper (Timbilt), 4/19/2014

require_relative 'wake_on_lan'

class Program
	MAC_PROVIDED_COUNT = 2
	MAC_AND_HOST_OR_PORT_PROVIDED_COUNT = 4
	MAC_AND_HOST_AND_PORT_PROVIDED_COUNT = 6
	
	def initialize
		@mac_flag, @host_flag, @port_flag = *@valid_flags = ['-m', '-h', '-p']
		*@valid_arg_count = [MAC_PROVIDED_COUNT, MAC_AND_HOST_OR_PORT_PROVIDED_COUNT, MAC_AND_HOST_AND_PORT_PROVIDED_COUNT]
		@arg_count = ARGV.size
	end
	
	def run
		if valid_arg_count?
			if only_mac_provided?
				WakeOnLAN.new get_mac
				wol.wake
			elsif mac_and_host_or_port_provided?
				if given_flags.include? @host_flag
					wol = WakeOnLAN.new get_mac, get_host, WakeOnLAN::DEFAULT_PORT
					wol.wake
				else
					wol = WakeOnLAN.new get_mac, WakeOnLAN::DEFAULT_HOST, get_port
					wol.wake
				end
			elsif mac_and_host_and_port_provided?
				wol = WakeOnLAN.new get_mac, get_host, get_port
				wol.wake
			end
		else
			show_usage
		end
	end
	
	private
	
	def arg_count
		ARGV.size
	end
	
	def valid_arg_count?
		@valid_arg_count.include? @arg_count
	end
	
	def given_flags
		ARGV.each_slice(2).collect { |pair| pair.first }
	end
	
	def get_arg flag
		ARGV.each_slice(2).find { |pair| pair.include? flag } .last
	end
	
	def get_mac
		get_arg @mac_flag
	end
	
	def get_host
		get_arg @host_flag
	end
	
	def get_port
		get_arg @port_flag
	end
	
	def only_mac_provided?
		given_flags.include? @mac_flag and arg_count.eql? MAC_PROVIDED_COUNT
	end
	
	def mac_and_host_or_port_provided?
		given_flags.all? { |f| @valid_flags.include? f } and @arg_count.eql? MAC_AND_HOST_OR_PORT_PROVIDED_COUNT
	end
	
	def mac_and_host_and_port_provided?
		given_flags.all? { |f| @valid_flags.include? f } and @arg_count.eql? MAC_AND_HOST_AND_PORT_PROVIDED_COUNT
	end
	
	def show_usage
		print	"\nWakeOnLAN 1.0 by Delano Cooper\n\n"\
					"Usage: send_wol_message -m <mac_address> [ -h <host_name_or_ip> ] [ -p <port_number> ]"\
					"\n\nExample 1: Wake host with mac address 11-22-33-44-55-66 on your subnet."\
					"\n\n\tsend_wol_message -m 11-22-33-44-55-66"\
					"\n\nExample 1: Wake host with mac address 11-22-33-44-55-66 on your subnet, broadcast IP."\
					"\n\n\tsend_wol_message -m 11-22-33-44-55-66 -h 192.168.1.255"\
					"\n\nExample 2: Wake host with mac address 00:11:22:33:44:55 on a different subnet."\
					"\n\n\tsend_wol_message -m 00:11:22:33:44:55 -h home.dyndns.org -p 30009\n"\
					"\tsend_wol_message -m 00:11:22:33:44:55 -h 170.20.1.31 -p 51001"\
					"\n\nYou should forward the ports to port 9 for the target host(s).  "\
					"NAT forward to the broadcast IP to enable sending different wake messages "\
					"to different remote hosts.  Eg. Forward port 30009 to 192.168.1.255, port 9.  You will "\
					"then be able to wake up any host from 192.168.1.2 to 192.168.1.254 while you are on a "\
					"remote network.\n\n"
	end

end

# run the program
Program.new.run