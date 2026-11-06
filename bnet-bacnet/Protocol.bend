import Base

# bnet-bacnet: BvlcHeader fields identify this protocol.
# BVLC type 129, function 10, length 24, so 20 octets follow the 4-octet header.

type BvlcHeader is Data:
  BvlcHeader{bvlc_type: U32, bvlc_function: U32, length: U32}

def is_bacnet_ip(header: BvlcHeader) -> Bool:
  match header:
    case BvlcHeader{bvlc_type, bvlc_function, length}:
      U32.is_eq(bvlc_type, 129)

def label(header: BvlcHeader) -> String:
  match header:
    case BvlcHeader{bvlc_type, bvlc_function, length}:
      "BACNET " ++ U32.show(bvlc_type) ++ " " ++ U32.show(bvlc_function) ++ " " ++ U32.show((length - 4 : U32))

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

# Four octets: BVLC type, function, and length.

def build_header(header: BvlcHeader) -> List<U32>:
  match header:
      case BvlcHeader{bvlc_type, bvlc_function, length}:
        cat(be_u8(bvlc_type), cat(be_u8(bvlc_function), be_u16(length)))

def parse_len(bvlc_type: U32, bvlc_function: U32, got: U32 & List<U32>) -> BvlcHeader:
  (length, rest) = got
  BvlcHeader{bvlc_type, bvlc_function, length}

def parse_fn(bvlc_type: U32, got: U32 & List<U32>) -> BvlcHeader:
  (bvlc_function, xs) = got
  parse_len(bvlc_type, bvlc_function, take_u16(xs))

def parse_ty(got: U32 & List<U32>) -> BvlcHeader:
  (bvlc_type, xs) = got
  parse_fn(bvlc_type, take_u8(xs))

def parse_header(xs: List<U32>) -> BvlcHeader:
  parse_ty(take_u8(xs))

def frame_fields(frame: BvlcHeader) -> U32 & U32 & U32:
  match frame:
    case BvlcHeader{bvlc_type, bvlc_function, length}:
      (bvlc_type, bvlc_function, length)

def same_rest(bvlc_type1: U32, bvlc_function1: U32, length1: U32, y: U32 & U32 & U32) -> Bool:
  (bvlc_type2, bvlc_function2, length2) = y
  both(both(U32.is_eq(bvlc_type1, bvlc_type2), U32.is_eq(bvlc_function1, bvlc_function2)), U32.is_eq(length1, length2))

def same_left(x: U32 & U32 & U32, y: U32 & U32 & U32) -> Bool:
  (bvlc_type1, bvlc_function1, length1) = x
  same_rest(bvlc_type1, bvlc_function1, length1, y)

def same_frame(a: BvlcHeader, b: BvlcHeader) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
