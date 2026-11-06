import Base

# bnet-udp: UdpDatagram fields identify this protocol.
# Port pair 40534 to 53. Length 28 includes the 8-octet header, so the payload is 20.

type UdpDatagram is Data:
  UdpDatagram{src_port: U32, dst_port: U32, length: U32, checksum: U32}

def is_dns_port(dgram: UdpDatagram) -> Bool:
  match dgram:
    case UdpDatagram{src_port, dst_port, length, checksum}:
      U32.is_eq(dst_port, 53)

def label(dgram: UdpDatagram) -> String:
  match dgram:
    case UdpDatagram{src_port, dst_port, length, checksum}:
      "UDP " ++ U32.show(src_port) ++ " " ++ U32.show(dst_port) ++ " " ++ U32.show((length - 8 : U32))
