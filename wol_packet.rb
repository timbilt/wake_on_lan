# Wake On LAN Magic Packet Utility
# by Delano Cooper (Timbilt), 4/19/2014

class WOLPacket

	MAC_SIZE = 6
	MARKER_SIZE = 6
	MARKER_UNIT = 0xFF
	PAYLOAD_SIZE = 102
	
	Invalid_MAC_Type_Error = "Expected String or Array"
	Invalid_MAC_String_Error = "Invalid MAC String"
	Invalid_MAC_Array_Error = "Invalid MAC Array"
	
	
	def initialize mac
		if mac.instance_of? String
			init_with_mac_string mac
		elsif mac.instance_of? Array
			init_with_mac_array mac
		else
			raise TypeError, Invalid_MAC_Type_Error
		end		
	end
	
	def payload
		payload_marker_part + payload_mac_part
	end
	
private
	
	def payload_marker_part
		[0xFF] * 6
	end
	
	def payload_mac_part
		@mac * 16
	end
	
	def validate_mac mac
		valid_mac_expression = /(([0-9a-f]){2}(:|-)){5}([0-9a-f]){2}/i
		mac.match valid_mac_expression
	end
	
	def get_mac_bytes_from_string mac
		mac.split(/:|-/).map { |x| x.hex }
	end
	
	def init_with_mac_string mac
		raise RuntimeError, Invalid_MAC_String_Error unless validate_mac mac			
		@mac = get_mac_bytes_from_string mac
	end
	
	def init_with_mac_array mac
		raise RuntimeError, Invalid_MAC_Array_Error unless mac.size == MAC_SIZE and mac.all? { |x| x.is_a? Integer }
		@mac = mac
	end
	
end