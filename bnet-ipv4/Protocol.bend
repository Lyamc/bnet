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

# Twenty octets. Version and IHL share the first byte. Total length, protocol, and checksum sit at their IPv4 offsets. The other bytes are zero.

def build_header(header: Ipv4Header) -> List<U32>:
  match header:
      case Ipv4Header{version, ihl, total_length, protocol, checksum}:
        cat(be_u8(pack_nib(version, ihl)), cat(be_u8(0), cat(be_u16(total_length), cat(be_u16(0), cat(be_u16(0), cat(be_u8(0), cat(be_u8(protocol), cat(be_u16(checksum), cat(be_u32(0), be_u32(0))))))))))

def parse_sum(version: U32, ihl: U32, total_length: U32, protocol: U32, got: U32 & List<U32>) -> Ipv4Header:
  (checksum, rest) = got
  Ipv4Header{version, ihl, total_length, protocol, checksum}

def parse_proto(version: U32, ihl: U32, total_length: U32, got: U32 & List<U32>) -> Ipv4Header:
  (protocol, xs) = got
  parse_sum(version, ihl, total_length, protocol, take_u16(xs))

def parse_after_len(version: U32, ihl: U32, total_length: U32, xs: List<U32>) -> Ipv4Header:
  parse_proto(version, ihl, total_length, take_u8(drop_n(1n, drop_n(4n, xs))))

def parse_len(version: U32, ihl: U32, got: U32 & List<U32>) -> Ipv4Header:
  (total_length, xs) = got
  parse_after_len(version, ihl, total_length, xs)

def parse_tos(ns: U32 & U32, xs: List<U32>) -> Ipv4Header:
  (version, ihl) = ns
  parse_len(version, ihl, take_u16(drop_n(1n, xs)))

def parse_vi(got: U32 & List<U32>) -> Ipv4Header:
  (byte0, xs) = got
  parse_tos(nibs(byte0), xs)

def parse_header(xs: List<U32>) -> Ipv4Header:
  parse_vi(take_u8(xs))

def frame_fields(frame: Ipv4Header) -> U32 & U32 & U32 & U32 & U32:
  match frame:
    case Ipv4Header{version, ihl, total_length, protocol, checksum}:
      (version, ihl, total_length, protocol, checksum)

def same_rest(version1: U32, ihl1: U32, total_length1: U32, protocol1: U32, checksum1: U32, y: U32 & U32 & U32 & U32 & U32) -> Bool:
  (version2, ihl2, total_length2, protocol2, checksum2) = y
  both(both(both(U32.is_eq(version1, version2), U32.is_eq(ihl1, ihl2)), both(U32.is_eq(total_length1, total_length2), U32.is_eq(protocol1, protocol2))), U32.is_eq(checksum1, checksum2))

def same_left(x: U32 & U32 & U32 & U32 & U32, y: U32 & U32 & U32 & U32 & U32) -> Bool:
  (version1, ihl1, total_length1, protocol1, checksum1) = x
  same_rest(version1, ihl1, total_length1, protocol1, checksum1, y)

def same_frame(a: Ipv4Header, b: Ipv4Header) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
