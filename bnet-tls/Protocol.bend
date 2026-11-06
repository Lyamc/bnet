import Base

# bnet-tls: TlsRecord fields identify this protocol.
# Content type 22 (handshake), version 3.3, length 40, so the record is 45 octets.

type TlsRecord is Data:
  TlsRecord{content_type: U32, major: U32, minor: U32, length: U32}

def is_handshake(rec: TlsRecord) -> Bool:
  match rec:
    case TlsRecord{content_type, major, minor, length}:
      U32.is_eq(content_type, 22)

def label(rec: TlsRecord) -> String:
  match rec:
    case TlsRecord{content_type, major, minor, length}:
      "TLS " ++ U32.show(content_type) ++ " " ++ U32.show(major) ++ "." ++ U32.show(minor) ++ " " ++ U32.show((length + 5 : U32))

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

# Five octets: content type, major, minor, and the record length.

def build_header(rec: TlsRecord) -> List<U32>:
  match rec:
      case TlsRecord{content_type, major, minor, length}:
        cat(be_u8(content_type), cat(be_u8(major), cat(be_u8(minor), be_u16(length))))

def parse_len(content_type: U32, major: U32, minor: U32, got: U32 & List<U32>) -> TlsRecord:
  (length, rest) = got
  TlsRecord{content_type, major, minor, length}

def parse_minor(content_type: U32, major: U32, got: U32 & List<U32>) -> TlsRecord:
  (minor, xs) = got
  parse_len(content_type, major, minor, take_u16(xs))

def parse_major(content_type: U32, got: U32 & List<U32>) -> TlsRecord:
  (major, xs) = got
  parse_minor(content_type, major, take_u8(xs))

def parse_type(got: U32 & List<U32>) -> TlsRecord:
  (content_type, xs) = got
  parse_major(content_type, take_u8(xs))

def parse_header(xs: List<U32>) -> TlsRecord:
  parse_type(take_u8(xs))

def frame_fields(frame: TlsRecord) -> U32 & U32 & U32 & U32:
  match frame:
    case TlsRecord{content_type, major, minor, length}:
      (content_type, major, minor, length)

def same_rest(content_type1: U32, major1: U32, minor1: U32, length1: U32, y: U32 & U32 & U32 & U32) -> Bool:
  (content_type2, major2, minor2, length2) = y
  both(both(U32.is_eq(content_type1, content_type2), U32.is_eq(major1, major2)), both(U32.is_eq(minor1, minor2), U32.is_eq(length1, length2)))

def same_left(x: U32 & U32 & U32 & U32, y: U32 & U32 & U32 & U32) -> Bool:
  (content_type1, major1, minor1, length1) = x
  same_rest(content_type1, major1, minor1, length1, y)

def same_frame(a: TlsRecord, b: TlsRecord) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
