import Base

# bnet-tcp: TcpSegment fields identify this protocol.
# Port pair 54321 to 443. Flags 2 is SYN. Data offset 5 is a 20-octet header.

type TcpSegment is Data:
  TcpSegment{src_port: U32, dst_port: U32, seq: U32, flags: U32, window: U32, data_offset: U32}

def is_syn(seg: TcpSegment) -> Bool:
  match seg:
    case TcpSegment{src_port, dst_port, seq, flags, window, data_offset}:
      U32.is_eq((flags .&. 2 : U32), 2)

def label(seg: TcpSegment) -> String:
  match seg:
    case TcpSegment{src_port, dst_port, seq, flags, window, data_offset}:
      "TCP " ++ U32.show(src_port) ++ " " ++ U32.show(dst_port) ++ " " ++ U32.show(flags) ++ " " ++ U32.show((data_offset * 4 : U32))

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

# Twenty octets: ports, sequence, a zero acknowledgement, data offset, flags, window, then zero checksum and urgent fields.

def build_header(seg: TcpSegment) -> List<U32>:
  match seg:
      case TcpSegment{src_port, dst_port, seq, flags, window, data_offset}:
        cat(be_u16(src_port), cat(be_u16(dst_port), cat(be_u32(seq), cat(be_u32(0), cat(be_u8((data_offset * 16 : U32)), cat(be_u8(flags), cat(be_u16(window), cat(be_u16(0), be_u16(0)))))))))

def nib_hi(n: U32) -> U32:
  (U32.shrn(n, 4n) .&. 15 : U32)

def parse_win(src_port: U32, dst_port: U32, seq: U32, flags: U32, data_offset: U32, got: U32 & List<U32>) -> TcpSegment:
  (window, rest) = got
  TcpSegment{src_port, dst_port, seq, flags, window, data_offset}

def parse_flags(src_port: U32, dst_port: U32, seq: U32, data_offset: U32, got: U32 & List<U32>) -> TcpSegment:
  (flags, xs) = got
  parse_win(src_port, dst_port, seq, flags, data_offset, take_u16(xs))

def parse_off(src_port: U32, dst_port: U32, seq: U32, got: U32 & List<U32>) -> TcpSegment:
  (off_byte, xs) = got
  parse_flags(src_port, dst_port, seq, nib_hi(off_byte), take_u8(xs))

def parse_seq(src_port: U32, dst_port: U32, got: U32 & List<U32>) -> TcpSegment:
  (seq, xs) = got
  parse_off(src_port, dst_port, seq, take_u8(drop_n(4n, xs)))

def parse_dst(src_port: U32, got: U32 & List<U32>) -> TcpSegment:
  (dst_port, xs) = got
  parse_seq(src_port, dst_port, take_u32(xs))

def parse_sport(got: U32 & List<U32>) -> TcpSegment:
  (src_port, xs) = got
  parse_dst(src_port, take_u16(xs))

def parse_header(xs: List<U32>) -> TcpSegment:
  parse_sport(take_u16(xs))

def frame_fields(frame: TcpSegment) -> U32 & U32 & U32 & U32 & U32 & U32:
  match frame:
    case TcpSegment{src_port, dst_port, seq, flags, window, data_offset}:
      (src_port, dst_port, seq, flags, window, data_offset)

def same_rest(src_port1: U32, dst_port1: U32, seq1: U32, flags1: U32, window1: U32, data_offset1: U32, y: U32 & U32 & U32 & U32 & U32 & U32) -> Bool:
  (src_port2, dst_port2, seq2, flags2, window2, data_offset2) = y
  both(both(both(U32.is_eq(src_port1, src_port2), U32.is_eq(dst_port1, dst_port2)), both(U32.is_eq(seq1, seq2), U32.is_eq(flags1, flags2))), both(U32.is_eq(window1, window2), U32.is_eq(data_offset1, data_offset2)))

def same_left(x: U32 & U32 & U32 & U32 & U32 & U32, y: U32 & U32 & U32 & U32 & U32 & U32) -> Bool:
  (src_port1, dst_port1, seq1, flags1, window1, data_offset1) = x
  same_rest(src_port1, dst_port1, seq1, flags1, window1, data_offset1, y)

def same_frame(a: TcpSegment, b: TcpSegment) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
