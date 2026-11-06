import Base

# bnet-arp: ArpMessage fields identify this protocol.
# Opcode 1 (request), protocol type 2048, hardware length 6, protocol length 4.

type ArpMessage is Data:
  ArpMessage{htype: U32, ptype: U32, hlen: U32, plen: U32, oper: U32}

def is_request(msg: ArpMessage) -> Bool:
  match msg:
    case ArpMessage{htype, ptype, hlen, plen, oper}:
      U32.is_eq(oper, 1)

def label(msg: ArpMessage) -> String:
  match msg:
    case ArpMessage{htype, ptype, hlen, plen, oper}:
      "ARP " ++ U32.show(oper) ++ " " ++ U32.show(ptype) ++ " " ++ U32.show(hlen) ++ " " ++ U32.show(plen)
