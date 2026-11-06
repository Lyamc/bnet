import Base

# bnet-websocket: WsFrame fields identify this protocol.
# Opcode 1 (text), FIN 1, payload 5, masking key 4 octets.

type WsFrame is Data:
  WsFrame{fin: U32, opcode: U32, masked: U32, payload_len: U32}

def mask_len(is_masked: Bool) -> U32:
  match is_masked:
    case True{}:
      4
    case False{}:
      0

def is_text(frame: WsFrame) -> Bool:
  match frame:
    case WsFrame{fin, opcode, masked, payload_len}:
      U32.is_eq(opcode, 1)

def label(frame: WsFrame) -> String:
  match frame:
    case WsFrame{fin, opcode, masked, payload_len}:
      "WEBSOCKET " ++ U32.show(opcode) ++ " " ++ U32.show(fin) ++ " " ++ U32.show(payload_len) ++ " " ++ U32.show(mask_len(U32.is_eq(masked, 1)))

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

# Six octets: FIN and opcode, mask bit and payload length, then a 4-octet mask.

def build_header(frame: WsFrame) -> List<U32>:
  match frame:
      case WsFrame{fin, opcode, masked, payload_len}:
        cat(be_u8(((fin * 128 : U32) + (opcode .&. 15 : U32) : U32)), cat(be_u8(((masked * 128 : U32) + (payload_len .&. 127 : U32) : U32)), zeros(4n)))

def bits7(n: U32) -> U32:
  (U32.shrn(n, 7n) .&. 1 : U32)

def low4(n: U32) -> U32:
  (n .&. 15 : U32)

def low7(n: U32) -> U32:
  (n .&. 127 : U32)

def parse_pay(fin: U32, opcode: U32, +byte1: U32) -> WsFrame:
  WsFrame{fin, opcode, bits7(byte1), low7(byte1)}

def parse_got(fin: U32, opcode: U32, got: U32 & List<U32>) -> WsFrame:
  (byte1, rest) = got
  parse_pay(fin, opcode, byte1)

def parse_both(+byte0: U32, xs: List<U32>) -> WsFrame:
  parse_got(bits7(byte0), low4(byte0), take_u8(xs))

def parse_fin(got: U32 & List<U32>) -> WsFrame:
  (byte0, xs) = got
  parse_both(byte0, xs)

def parse_header(xs: List<U32>) -> WsFrame:
  parse_fin(take_u8(xs))

def frame_fields(frame: WsFrame) -> U32 & U32 & U32 & U32:
  match frame:
    case WsFrame{fin, opcode, masked, payload_len}:
      (fin, opcode, masked, payload_len)

def same_rest(fin1: U32, opcode1: U32, masked1: U32, payload_len1: U32, y: U32 & U32 & U32 & U32) -> Bool:
  (fin2, opcode2, masked2, payload_len2) = y
  both(both(U32.is_eq(fin1, fin2), U32.is_eq(opcode1, opcode2)), both(U32.is_eq(masked1, masked2), U32.is_eq(payload_len1, payload_len2)))

def same_left(x: U32 & U32 & U32 & U32, y: U32 & U32 & U32 & U32) -> Bool:
  (fin1, opcode1, masked1, payload_len1) = x
  same_rest(fin1, opcode1, masked1, payload_len1, y)

def same_frame(a: WsFrame, b: WsFrame) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
