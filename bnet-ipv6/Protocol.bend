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

# Forty octets. Version is the high nibble. Payload length, next header, and hop limit follow. The address bytes are zero.

def build_header(header: Ipv6Header) -> List<U32>:
  match header:
      case Ipv6Header{version, payload_length, next_header, hop_limit}:
        cat(be_u8((version * 16 : U32)), cat(zeros(3n), cat(be_u16(payload_length), cat(be_u8(next_header), cat(be_u8(hop_limit), zeros(32n))))))

def ver_of(n: U32) -> U32:
  (U32.shrn(n, 4n) .&. 15 : U32)

def parse_hop(version: U32, payload_length: U32, next_header: U32, got: U32 & List<U32>) -> Ipv6Header:
  (hop_limit, rest) = got
  Ipv6Header{version, payload_length, next_header, hop_limit}

def parse_next(version: U32, payload_length: U32, got: U32 & List<U32>) -> Ipv6Header:
  (next_header, xs) = got
  parse_hop(version, payload_length, next_header, take_u8(xs))

def parse_plen(version: U32, got: U32 & List<U32>) -> Ipv6Header:
  (payload_length, xs) = got
  parse_next(version, payload_length, take_u8(xs))

def parse_ver(got: U32 & List<U32>) -> Ipv6Header:
  (byte0, xs) = got
  parse_plen(ver_of(byte0), take_u16(drop_n(3n, xs)))

def parse_header(xs: List<U32>) -> Ipv6Header:
  parse_ver(take_u8(xs))

def frame_fields(frame: Ipv6Header) -> U32 & U32 & U32 & U32:
  match frame:
    case Ipv6Header{version, payload_length, next_header, hop_limit}:
      (version, payload_length, next_header, hop_limit)

def same_rest(version1: U32, payload_length1: U32, next_header1: U32, hop_limit1: U32, y: U32 & U32 & U32 & U32) -> Bool:
  (version2, payload_length2, next_header2, hop_limit2) = y
  both(both(U32.is_eq(version1, version2), U32.is_eq(payload_length1, payload_length2)), both(U32.is_eq(next_header1, next_header2), U32.is_eq(hop_limit1, hop_limit2)))

def same_left(x: U32 & U32 & U32 & U32, y: U32 & U32 & U32 & U32) -> Bool:
  (version1, payload_length1, next_header1, hop_limit1) = x
  same_rest(version1, payload_length1, next_header1, hop_limit1, y)

def same_frame(a: Ipv6Header, b: Ipv6Header) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
