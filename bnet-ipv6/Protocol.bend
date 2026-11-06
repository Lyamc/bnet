import Base

# bnet-ipv6: Ipv6Header fields identify this protocol.
# Version 6, next header 17 (UDP), payload 32, so 40 + 32 = 72 octets.

type Ipv6Header is Data:
  Ipv6Header{version: U32, payload_length: U32, next_header: U32, hop_limit: U32}

def is_version_6(header: Ipv6Header) -> Bool:
  match header:
    case Ipv6Header{version, payload_length, next_header, hop_limit}:
      U32.is_eq(version, 6)

def label(header: Ipv6Header) -> String:
  match header:
    case Ipv6Header{version, payload_length, next_header, hop_limit}:
      "IPV6 " ++ U32.show(version) ++ " " ++ U32.show(next_header) ++ " " ++ U32.show((40 + payload_length : U32))
