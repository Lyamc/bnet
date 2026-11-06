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

# The 14-octet header stores each modeled field: dst and src as 4 octets,
# ethertype as 2, and payload_len as 4.

def be_u16(+n: U32) -> List<U32>:
  (U32.shrn(n, 8n) .&. 255 : U32) <> (n .&. 255 : U32) <> Nil{}

def be_u32(+n: U32) -> List<U32>:
  (U32.shrn(n, 24n) .&. 255 : U32) <> (U32.shrn(n, 16n) .&. 255 : U32) <> (U32.shrn(n, 8n) .&. 255 : U32) <> (n .&. 255 : U32) <> Nil{}

def cat(xs: List<U32>, ys: List<U32>) -> List<U32>:
  List.append(&1, U32, xs, ys)

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

def build_header(frame: EtherFrame) -> List<U32>:
  match frame:
    case EtherFrame{dst, src, ethertype, payload_len}:
      cat(be_u32(dst), cat(be_u32(src), cat(be_u16(ethertype), be_u32(payload_len))))

def parse_done(dst: U32, src: U32, ethertype: U32, got: U32 & List<U32>) -> EtherFrame:
  (payload_len, rest) = got
  EtherFrame{dst, src, ethertype, payload_len}

def parse_plen(dst: U32, src: U32, got: U32 & List<U32>) -> EtherFrame:
  (ethertype, xs) = got
  parse_done(dst, src, ethertype, take_u32(xs))

def parse_etype(dst: U32, got: U32 & List<U32>) -> EtherFrame:
  (src, xs) = got
  parse_plen(dst, src, take_u16(xs))

def parse_src(got: U32 & List<U32>) -> EtherFrame:
  (dst, xs) = got
  parse_etype(dst, take_u32(xs))

def parse_header(xs: List<U32>) -> EtherFrame:
  parse_src(take_u32(xs))

def frame_fields(frame: EtherFrame) -> U32 & U32 & U32 & U32:
  match frame:
    case EtherFrame{dst, src, ethertype, payload_len}:
      (dst, src, ethertype, payload_len)

def same_rest(d1: U32, s1: U32, e1: U32, p1: U32, y: U32 & U32 & U32 & U32) -> Bool:
  (d2, s2, e2, p2) = y
  both(both(U32.is_eq(d1, d2), U32.is_eq(s1, s2)), both(U32.is_eq(e1, e2), U32.is_eq(p1, p2)))

def same_left(x: U32 & U32 & U32 & U32, y: U32 & U32 & U32 & U32) -> Bool:
  (d1, s1, e1, p1) = x
  same_rest(d1, s1, e1, p1, y)

def same_frame(a: EtherFrame, b: EtherFrame) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
