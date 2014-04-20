# Wake On LAN Magic Packet Utility
# by Delano Cooper (Timbilt), 4/19/2014

require_relative '../wol_packet'
require_relative '../wake_on_lan'

PORT = WakeOnLAN::DEFAULT_PORT
HOST = WakeOnLAN::DEFAULT_HOST
Valid_MAC_String = "00:22:44:88:AA:ff"
Valid_MAC_Bytes = [0x00, 0x22, 0x44, 0x88, 0xAA, 0xff]

describe "wake a sleeping computer" do

  describe "wol packet" do

    before(:all) do
      @wol_packet = WOLPacket.new Valid_MAC_String
    end

    it "initializes with one argument" do		
      expect { WOLPacket.new }.to raise_error(ArgumentError)
    end
    
    it "initializes with String or Array object only" do
      expect { WOLPacket.new 11_22_33_44_55_66 }.to raise_error(WOLPacket::Invalid_MAC_Type_Error)
    end
    
    it "initializes with string of colon/hyphen separated bytes" do
      expect { WOLPacket.new "1:2:3:4:5:f" }.to raise_error(WOLPacket::Invalid_MAC_String_Error)
      expect { WOLPacket.new "11_22_33_44_55_66" }.to raise_error(WOLPacket::Invalid_MAC_String_Error)
      
      expect(WOLPacket.new "11:22:33:44:55:66").to be_instance_of(WOLPacket)
      expect(WOLPacket.new "00-22-33-44-55-66").to be_instance_of(WOLPacket)
    end
    
    it "initializes with an array of 8 integers" do
      expect { WOLPacket.new [] }.to raise_error(RuntimeError, WOLPacket::Invalid_MAC_Array_Error)
      expect { WOLPacket.new [11, '22', "33", 0x44, 0x55, 0x66] }.to raise_error(WOLPacket::Invalid_MAC_Array_Error)
      
      expect(WOLPacket.new [0, 11, 0x22, 0x33, 0x44, 0xFF]).to be_instance_of(WOLPacket)
    end
    
    it "starts with 6-byte marker" do
      expect(@wol_packet.payload).to start_with([WOLPacket::MARKER_UNIT] * 6)
    end
    
    it "ends with 16 mac address repetitions" do
      expect(@wol_packet.payload).to end_with(Valid_MAC_Bytes * 16)
    end
    
  end

  describe "wake-up message sender" do

    before(:all) do
      mac, host, port = Valid_MAC_String, WakeOnLAN::DEFAULT_HOST, WakeOnLAN::DEFAULT_PORT
      @wol = WakeOnLAN.new mac, host, port
    end

    it "initializes with 1, 2, or 3 arguments" do
      expect { WakeOnLAN.new }.to raise_error(WakeOnLAN::Invalid_Number_Of_Arguments_Error)
    end
    
    it "initialization must specify a mac (String)" do 
      expect { WakeOnLAN.new WakeOnLAN::DEFAULT_HOST}.to raise_error(WOLPacket::Invalid_MAC_String_Error)
      expect { WakeOnLAN.new WakeOnLAN::DEFAULT_PORT}.to raise_error(WOLPacket::Invalid_MAC_Type_Error)
    end
    
    it "initialization argument order must be mac, host, port" do
      expect { (WakeOnLAN.new Valid_MAC_String, PORT, HOST).wake }.to raise_error(SocketError)
    end
    
    it "has a payload of 102 bytes" do			
      expect(@wol.payload.size).to eq(WOLPacket::PAYLOAD_SIZE)
    end
    
    it "sends a payload of 102 bytes" do
      expect(@wol.wake).to eq(WOLPacket::PAYLOAD_SIZE)
    end

  end

end