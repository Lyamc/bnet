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

# Eight octets: hardware type, protocol type, hardware length, protocol length, opcode.

def build_header(msg: ArpMessage) -> List<U32>:
  match msg:
      case ArpMessage{htype, ptype, hlen, plen, oper}:
        cat(be_u16(htype), cat(be_u16(ptype), cat(be_u8(hlen), cat(be_u8(plen), be_u16(oper)))))

def parse_oper(htype: U32, ptype: U32, hlen: U32, plen: U32, got: U32 & List<U32>) -> ArpMessage:
  (oper, rest) = got
  ArpMessage{htype, ptype, hlen, plen, oper}

def parse_plen(htype: U32, ptype: U32, hlen: U32, got: U32 & List<U32>) -> ArpMessage:
  (plen, xs) = got
  parse_oper(htype, ptype, hlen, plen, take_u16(xs))

def parse_hlen(htype: U32, ptype: U32, got: U32 & List<U32>) -> ArpMessage:
  (hlen, xs) = got
  parse_plen(htype, ptype, hlen, take_u8(xs))

def parse_ptype(htype: U32, got: U32 & List<U32>) -> ArpMessage:
  (ptype, xs) = got
  parse_hlen(htype, ptype, take_u8(xs))

def parse_htype(got: U32 & List<U32>) -> ArpMessage:
  (htype, xs) = got
  parse_ptype(htype, take_u16(xs))

def parse_header(xs: List<U32>) -> ArpMessage:
  parse_htype(take_u16(xs))

def frame_fields(frame: ArpMessage) -> U32 & U32 & U32 & U32 & U32:
  match frame:
    case ArpMessage{htype, ptype, hlen, plen, oper}:
      (htype, ptype, hlen, plen, oper)

def same_rest(htype1: U32, ptype1: U32, hlen1: U32, plen1: U32, oper1: U32, y: U32 & U32 & U32 & U32 & U32) -> Bool:
  (htype2, ptype2, hlen2, plen2, oper2) = y
  both(both(both(U32.is_eq(htype1, htype2), U32.is_eq(ptype1, ptype2)), both(U32.is_eq(hlen1, hlen2), U32.is_eq(plen1, plen2))), U32.is_eq(oper1, oper2))

def same_left(x: U32 & U32 & U32 & U32 & U32, y: U32 & U32 & U32 & U32 & U32) -> Bool:
  (htype1, ptype1, hlen1, plen1, oper1) = x
  same_rest(htype1, ptype1, hlen1, plen1, oper1, y)

def same_frame(a: ArpMessage, b: ArpMessage) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
