import Base

# bnet-modbus-rtu: RtuAdu fields identify this protocol.
# Function 3 (Read Holding Registers) and CRC 4660.

type RtuAdu is Data:
  RtuAdu{slave: U32, function: U32, start_addr: U32, quantity: U32, crc: U32}

def is_read_holding(adu: RtuAdu) -> Bool:
  match adu:
    case RtuAdu{slave, function, start_addr, quantity, crc}:
      U32.is_eq(function, 3)

def label(adu: RtuAdu) -> String:
  match adu:
    case RtuAdu{slave, function, start_addr, quantity, crc}:
      "MODBUS_RTU " ++ U32.show(function) ++ " " ++ U32.show(crc)

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

# Eight octets: slave, function, start address, quantity, and CRC.

def build_header(adu: RtuAdu) -> List<U32>:
  match adu:
      case RtuAdu{slave, function, start_addr, quantity, crc}:
        cat(be_u8(slave), cat(be_u8(function), cat(be_u16(start_addr), cat(be_u16(quantity), be_u16(crc)))))

def parse_crc(slave: U32, function: U32, start_addr: U32, quantity: U32, got: U32 & List<U32>) -> RtuAdu:
  (crc, rest) = got
  RtuAdu{slave, function, start_addr, quantity, crc}

def parse_qty(slave: U32, function: U32, start_addr: U32, got: U32 & List<U32>) -> RtuAdu:
  (quantity, xs) = got
  parse_crc(slave, function, start_addr, quantity, take_u16(xs))

def parse_start(slave: U32, function: U32, got: U32 & List<U32>) -> RtuAdu:
  (start_addr, xs) = got
  parse_qty(slave, function, start_addr, take_u16(xs))

def parse_fn(slave: U32, got: U32 & List<U32>) -> RtuAdu:
  (function, xs) = got
  parse_start(slave, function, take_u16(xs))

def parse_slave(got: U32 & List<U32>) -> RtuAdu:
  (slave, xs) = got
  parse_fn(slave, take_u8(xs))

def parse_header(xs: List<U32>) -> RtuAdu:
  parse_slave(take_u8(xs))

def frame_fields(frame: RtuAdu) -> U32 & U32 & U32 & U32 & U32:
  match frame:
    case RtuAdu{slave, function, start_addr, quantity, crc}:
      (slave, function, start_addr, quantity, crc)

def same_rest(slave1: U32, function1: U32, start_addr1: U32, quantity1: U32, crc1: U32, y: U32 & U32 & U32 & U32 & U32) -> Bool:
  (slave2, function2, start_addr2, quantity2, crc2) = y
  both(both(both(U32.is_eq(slave1, slave2), U32.is_eq(function1, function2)), both(U32.is_eq(start_addr1, start_addr2), U32.is_eq(quantity1, quantity2))), U32.is_eq(crc1, crc2))

def same_left(x: U32 & U32 & U32 & U32 & U32, y: U32 & U32 & U32 & U32 & U32) -> Bool:
  (slave1, function1, start_addr1, quantity1, crc1) = x
  same_rest(slave1, function1, start_addr1, quantity1, crc1, y)

def same_frame(a: RtuAdu, b: RtuAdu) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
