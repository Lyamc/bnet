import Base

# bnet-modbus-tcp: TcpMbap fields identify this protocol.
# Protocol id 0, function 3, length 6, so the ADU is 12 octets.

type TcpMbap is Data:
  TcpMbap{transaction_id: U32, protocol_id: U32, length: U32, unit_id: U32, function: U32}

def is_modbus(mbap: TcpMbap) -> Bool:
  match mbap:
    case TcpMbap{transaction_id, protocol_id, length, unit_id, function}:
      U32.is_eq(protocol_id, 0)

def label(mbap: TcpMbap) -> String:
  match mbap:
    case TcpMbap{transaction_id, protocol_id, length, unit_id, function}:
      "MODBUS_TCP " ++ U32.show(protocol_id) ++ " " ++ U32.show(function) ++ " " ++ U32.show((length + 6 : U32))

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

# Seven octets: transaction id, protocol id, length, unit id, and function.

def build_header(mbap: TcpMbap) -> List<U32>:
  match mbap:
      case TcpMbap{transaction_id, protocol_id, length, unit_id, function}:
        cat(be_u16(transaction_id), cat(be_u16(protocol_id), cat(be_u8(length), cat(be_u8(unit_id), be_u8(function)))))

def parse_fn(transaction_id: U32, protocol_id: U32, length: U32, unit_id: U32, got: U32 & List<U32>) -> TcpMbap:
  (function, rest) = got
  TcpMbap{transaction_id, protocol_id, length, unit_id, function}

def parse_unit(transaction_id: U32, protocol_id: U32, length: U32, got: U32 & List<U32>) -> TcpMbap:
  (unit_id, xs) = got
  parse_fn(transaction_id, protocol_id, length, unit_id, take_u8(xs))

def parse_len(transaction_id: U32, protocol_id: U32, got: U32 & List<U32>) -> TcpMbap:
  (length, xs) = got
  parse_unit(transaction_id, protocol_id, length, take_u8(xs))

def parse_pid(transaction_id: U32, got: U32 & List<U32>) -> TcpMbap:
  (protocol_id, xs) = got
  parse_len(transaction_id, protocol_id, take_u8(xs))

def parse_tid(got: U32 & List<U32>) -> TcpMbap:
  (transaction_id, xs) = got
  parse_pid(transaction_id, take_u16(xs))

def parse_header(xs: List<U32>) -> TcpMbap:
  parse_tid(take_u16(xs))

def frame_fields(frame: TcpMbap) -> U32 & U32 & U32 & U32 & U32:
  match frame:
    case TcpMbap{transaction_id, protocol_id, length, unit_id, function}:
      (transaction_id, protocol_id, length, unit_id, function)

def same_rest(transaction_id1: U32, protocol_id1: U32, length1: U32, unit_id1: U32, function1: U32, y: U32 & U32 & U32 & U32 & U32) -> Bool:
  (transaction_id2, protocol_id2, length2, unit_id2, function2) = y
  both(both(both(U32.is_eq(transaction_id1, transaction_id2), U32.is_eq(protocol_id1, protocol_id2)), both(U32.is_eq(length1, length2), U32.is_eq(unit_id1, unit_id2))), U32.is_eq(function1, function2))

def same_left(x: U32 & U32 & U32 & U32 & U32, y: U32 & U32 & U32 & U32 & U32) -> Bool:
  (transaction_id1, protocol_id1, length1, unit_id1, function1) = x
  same_rest(transaction_id1, protocol_id1, length1, unit_id1, function1, y)

def same_frame(a: TcpMbap, b: TcpMbap) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
