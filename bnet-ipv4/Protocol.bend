import Base

# bnet-ipv4: Ipv4Header fields identify this protocol.
# Version 4, protocol 6 (TCP), IHL 5 so the header is 20 octets.

type Ipv4Header is Data:
  Ipv4Header{version: U32, ihl: U32, total_length: U32, protocol: U32, checksum: U32}

def is_version_4(header: Ipv4Header) -> Bool:
  match header:
    case Ipv4Header{version, ihl, total_length, protocol, checksum}:
      U32.is_eq(version, 4)

def label(header: Ipv4Header) -> String:
  match header:
    case Ipv4Header{version, ihl, total_length, protocol, checksum}:
      "IPV4 " ++ U32.show(version) ++ " " ++ U32.show(protocol) ++ " " ++ U32.show((ihl * 4 : U32))
