import Base

# bnet-mqtt: MqttPacket fields identify this protocol.
# Packet type 1 (CONNECT), flags 0, remaining length 10, so the packet is 12 octets.

type MqttPacket is Data:
  MqttPacket{packet_type: U32, flags: U32, remaining_length: U32}

def is_connect(pkt: MqttPacket) -> Bool:
  match pkt:
    case MqttPacket{packet_type, flags, remaining_length}:
      U32.is_eq(packet_type, 1)

def label(pkt: MqttPacket) -> String:
  match pkt:
    case MqttPacket{packet_type, flags, remaining_length}:
      "MQTT " ++ U32.show(packet_type) ++ " " ++ U32.show(flags) ++ " " ++ U32.show((remaining_length + 2 : U32))
