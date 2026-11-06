import Base

# bnet-udp: UdpDatagram fields identify this protocol.
# Port pair 40534 to 53. Length 28 includes the 8-octet header, so the payload is 20.

type UdpDatagram is Data:
  UdpDatagram{src_port: U32, dst_port: U32, length: U32, checksum: U32}

def is_dns_port(dgram: UdpDatagram) -> Bool:
  match dgram:
    case UdpDatagram{src_port, dst_port, length, checksum}:
      U32.is_eq(dst_port, 53)

def label(dgram: UdpDatagram) -> String:
  match dgram:
    case UdpDatagram{src_port, dst_port, length, checksum}:
      "UDP " ++ U32.show(src_port) ++ " " ++ U32.show(dst_port) ++ " " ++ U32.show((length - 8 : U32))

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

# Eight octets: source port, destination port, length, checksum.

def build_header(dgram: UdpDatagram) -> List<U32>:
  match dgram:
      case UdpDatagram{src_port, dst_port, length, checksum}:
        cat(be_u16(src_port), cat(be_u16(dst_port), cat(be_u16(length), be_u16(checksum))))

def parse_sum(src_port: U32, dst_port: U32, length: U32, got: U32 & List<U32>) -> UdpDatagram:
  (checksum, rest) = got
  UdpDatagram{src_port, dst_port, length, checksum}

def parse_len(src_port: U32, dst_port: U32, got: U32 & List<U32>) -> UdpDatagram:
  (length, xs) = got
  parse_sum(src_port, dst_port, length, take_u16(xs))

def parse_dst(src_port: U32, got: U32 & List<U32>) -> UdpDatagram:
  (dst_port, xs) = got
  parse_len(src_port, dst_port, take_u16(xs))

def parse_src(got: U32 & List<U32>) -> UdpDatagram:
  (src_port, xs) = got
  parse_dst(src_port, take_u16(xs))

def parse_header(xs: List<U32>) -> UdpDatagram:
  parse_src(take_u16(xs))

def frame_fields(frame: UdpDatagram) -> U32 & U32 & U32 & U32:
  match frame:
    case UdpDatagram{src_port, dst_port, length, checksum}:
      (src_port, dst_port, length, checksum)

def same_rest(src_port1: U32, dst_port1: U32, length1: U32, checksum1: U32, y: U32 & U32 & U32 & U32) -> Bool:
  (src_port2, dst_port2, length2, checksum2) = y
  both(both(U32.is_eq(src_port1, src_port2), U32.is_eq(dst_port1, dst_port2)), both(U32.is_eq(length1, length2), U32.is_eq(checksum1, checksum2)))

def same_left(x: U32 & U32 & U32 & U32, y: U32 & U32 & U32 & U32) -> Bool:
  (src_port1, dst_port1, length1, checksum1) = x
  same_rest(src_port1, dst_port1, length1, checksum1, y)

def same_frame(a: UdpDatagram, b: UdpDatagram) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
