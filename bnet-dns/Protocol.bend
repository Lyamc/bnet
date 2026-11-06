import Base

# bnet-dns: DnsMessage fields identify this protocol.
# Flags 0, so QR is 0 (query). QTYPE 1 is A. One question.

type DnsMessage is Data:
  DnsMessage{ident: U32, flags: U32, qdcount: U32, qtype: U32}

def qr_bit(flags: U32) -> U32:
  (flags .&. 32768 : U32)

def is_query(msg: DnsMessage) -> Bool:
  match msg:
    case DnsMessage{ident, flags, qdcount, qtype}:
      U32.is_eq(qr_bit(flags), 0)

def label(msg: DnsMessage) -> String:
  match msg:
    case DnsMessage{ident, flags, qdcount, qtype}:
      "DNS " ++ U32.show(qr_bit(flags)) ++ " " ++ U32.show(qtype) ++ " " ++ U32.show(qdcount)
