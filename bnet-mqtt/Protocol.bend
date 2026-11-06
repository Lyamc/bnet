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

def be_u8(n: U32) -> List<U32>:
  (n .&. 255 : U32) <> Nil{}

def be_u16(+n: U32) -> List<U32>:
  (U32.shrn(n, 8n) .&. 255 : U32) <> (n .&. 255 : U32) <> Nil{}

def be_u32(+n: U32) -> List<U32>:
  (U32.shrn(n, 24n) .&. 255 : U32) <> (U32.shrn(n, 16n) .&. 255 : U32) <> (U32.shrn(n, 8n) .&. 255 : U32) <> (n .&. 255 : U32) <> Nil{}

def cat(xs: List<U32>, ys: List<U32>) -> List<U32>:
  List.append(&1, U32, xs, ys)

def zeros(n: Nat) -> List<U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+p:
      0 <> zeros(p)

def take_u8(xs: List<U32>) -> U32 & List<U32>:
  match xs:
    case Nil{}:
      (0, Nil{})
    case Con{head, tail}:
      ((head .&. 255 : U32), tail)

def take_u16_join(hi: U32, got: U32 & List<U32>) -> U32 & List<U32>:
  (lo, zs) = got
  (((hi * 256 : U32) + lo : U32), zs)

def take_u16_lo(got: U32 & List<U32>) -> U32 & List<U32>:
  (hi, ys) = got
  take_u16_join(hi, take_u8(ys))

def take_u16(xs: List<U32>) -> U32 & List<U32>:
  take_u16_lo(take_u8(xs))

def take_u32_join(hi: U32, got: U32 & List<U32>) -> U32 & List<U32>:
  (lo, zs) = got
  (((hi * 65536 : U32) + lo : U32), zs)

def take_u32_lo(got: U32 & List<U32>) -> U32 & List<U32>:
  (hi, ys) = got
  take_u32_join(hi, take_u16(ys))

def take_u32(xs: List<U32>) -> U32 & List<U32>:
  take_u32_lo(take_u16(xs))

def drop_n(n: Nat, xs: List<U32>) -> List<U32>:
  match n:
    case 0n:
      xs
    case 1n+p:
      drop_n(p, List.tail(&1, U32, xs))

def measure_con(head: U32, rec: U32 & List<U32>) -> U32 & List<U32>:
  (n, tail) = rec
  ((n + 1 : U32), head <> tail)

def measure(xs: List<U32>) -> U32 & List<U32>:
  match xs:
    case Nil{}:
      (0, Nil{})
    case Con{head, tail}:
      measure_con(head, measure(tail))

def both(a: Bool, b: Bool) -> Bool:
  Bool.and(a, b)

def pack_nib(hi: U32, lo: U32) -> U32:
  ((hi * 16 : U32) + (lo .&. 15 : U32) : U32)

def nibs(+n: U32) -> U32 & U32:
  ((U32.shrn(n, 4n) .&. 15 : U32), (n .&. 15 : U32))

# Two octets: packet type and flags in the first, remaining length in the second.

def build_header(pkt: MqttPacket) -> List<U32>:
  match pkt:
      case MqttPacket{packet_type, flags, remaining_length}:
        cat(be_u8(pack_nib(packet_type, flags)), be_u8(remaining_length))

def parse_built(packet_type: U32, flags: U32, got: U32 & List<U32>) -> MqttPacket:
  (remaining_length, rest) = got
  MqttPacket{packet_type, flags, remaining_length}

def parse_nibs(ns: U32 & U32, xs: List<U32>) -> MqttPacket:
  (packet_type, flags) = ns
  parse_built(packet_type, flags, take_u8(xs))

def parse_flags(got: U32 & List<U32>) -> MqttPacket:
  (byte0, xs) = got
  parse_nibs(nibs(byte0), xs)

def parse_header(xs: List<U32>) -> MqttPacket:
  parse_flags(take_u8(xs))

def frame_fields(frame: MqttPacket) -> U32 & U32 & U32:
  match frame:
    case MqttPacket{packet_type, flags, remaining_length}:
      (packet_type, flags, remaining_length)

def same_rest(packet_type1: U32, flags1: U32, remaining_length1: U32, y: U32 & U32 & U32) -> Bool:
  (packet_type2, flags2, remaining_length2) = y
  both(both(U32.is_eq(packet_type1, packet_type2), U32.is_eq(flags1, flags2)), U32.is_eq(remaining_length1, remaining_length2))

def same_left(x: U32 & U32 & U32, y: U32 & U32 & U32) -> Bool:
  (packet_type1, flags1, remaining_length1) = x
  same_rest(packet_type1, flags1, remaining_length1, y)

def same_frame(a: MqttPacket, b: MqttPacket) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
