import Base

# bnet-ethernet: EtherFrame fields identify this protocol.
# EtherType 2048 is IPv4. 14 + 64 = 78 octets of header plus payload.

type EtherFrame is Data:
  EtherFrame{dst: U32, src: U32, ethertype: U32, payload_len: U32}

def is_ipv4(frame: EtherFrame) -> Bool:
  match frame:
    case EtherFrame{dst, src, ethertype, payload_len}:
      U32.is_eq(ethertype, 2048)

def label(frame: EtherFrame) -> String:
  match frame:
    case EtherFrame{dst, src, ethertype, payload_len}:
      "ETHERNET " ++ U32.show(ethertype) ++ " " ++ U32.show((14 + payload_len : U32))
