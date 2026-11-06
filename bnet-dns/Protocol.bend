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

# Twelve octets: id, flags, question count, query type, and four trailing zeros.

def build_header(msg: DnsMessage) -> List<U32>:
  match msg:
      case DnsMessage{ident, flags, qdcount, qtype}:
        cat(be_u16(ident), cat(be_u16(flags), cat(be_u16(qdcount), cat(be_u16(qtype), zeros(4n)))))

def parse_qt(ident: U32, flags: U32, qdcount: U32, got: U32 & List<U32>) -> DnsMessage:
  (qtype, rest) = got
  DnsMessage{ident, flags, qdcount, qtype}

def parse_qd(ident: U32, flags: U32, got: U32 & List<U32>) -> DnsMessage:
  (qdcount, xs) = got
  parse_qt(ident, flags, qdcount, take_u16(xs))

def parse_flags(ident: U32, got: U32 & List<U32>) -> DnsMessage:
  (flags, xs) = got
  parse_qd(ident, flags, take_u16(xs))

def parse_id(got: U32 & List<U32>) -> DnsMessage:
  (ident, xs) = got
  parse_flags(ident, take_u16(xs))

def parse_header(xs: List<U32>) -> DnsMessage:
  parse_id(take_u16(xs))

def frame_fields(frame: DnsMessage) -> U32 & U32 & U32 & U32:
  match frame:
    case DnsMessage{ident, flags, qdcount, qtype}:
      (ident, flags, qdcount, qtype)

def same_rest(ident1: U32, flags1: U32, qdcount1: U32, qtype1: U32, y: U32 & U32 & U32 & U32) -> Bool:
  (ident2, flags2, qdcount2, qtype2) = y
  both(both(U32.is_eq(ident1, ident2), U32.is_eq(flags1, flags2)), both(U32.is_eq(qdcount1, qdcount2), U32.is_eq(qtype1, qtype2)))

def same_left(x: U32 & U32 & U32 & U32, y: U32 & U32 & U32 & U32) -> Bool:
  (ident1, flags1, qdcount1, qtype1) = x
  same_rest(ident1, flags1, qdcount1, qtype1, y)

def same_frame(a: DnsMessage, b: DnsMessage) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
