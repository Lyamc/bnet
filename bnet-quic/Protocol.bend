import Base

# bnet-quic: QuicLongHeader fields identify this protocol.
# Version 1. DCID 8 plus SCID 8 is 16 octets. Token length 0.

type QuicLongHeader is Data:
  QuicLongHeader{version: U32, dcid_len: U32, scid_len: U32, token_len: U32}

def is_version_1(header: QuicLongHeader) -> Bool:
  match header:
    case QuicLongHeader{version, dcid_len, scid_len, token_len}:
      U32.is_eq(version, 1)

def label(header: QuicLongHeader) -> String:
  match header:
    case QuicLongHeader{version, dcid_len, scid_len, token_len}:
      "QUIC " ++ U32.show(version) ++ " " ++ U32.show((dcid_len + scid_len : U32)) ++ " " ++ U32.show(token_len)

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

# Token length, version, destination-id length, that many zero octets, source-id length, and that many zero octets. The fixture is 23 octets.

def build_header(header: QuicLongHeader) -> List<U32>:
  match header:
      case QuicLongHeader{version, +dcid_len, +scid_len, token_len}:
        cat(be_u8(token_len), cat(be_u32(version), cat(be_u8(dcid_len), cat(zeros(U32.to_nat(dcid_len)), cat(be_u8(scid_len), zeros(U32.to_nat(scid_len)))))))

def parse_scid(token_len: U32, version: U32, dcid_len: U32, got: U32 & List<U32>) -> QuicLongHeader:
  (scid_len, rest) = got
  QuicLongHeader{version, dcid_len, scid_len, token_len}

def parse_drop(token_len: U32, version: U32, +dcid_len: U32, xs: List<U32>) -> QuicLongHeader:
  parse_scid(token_len, version, dcid_len, take_u8(drop_n(U32.to_nat(dcid_len), xs)))

def parse_dcid(token_len: U32, version: U32, got: U32 & List<U32>) -> QuicLongHeader:
  (dcid_len, xs) = got
  parse_drop(token_len, version, dcid_len, xs)

def parse_ver(token_len: U32, got: U32 & List<U32>) -> QuicLongHeader:
  (version, xs) = got
  parse_dcid(token_len, version, take_u8(xs))

def parse_tok(got: U32 & List<U32>) -> QuicLongHeader:
  (token_len, xs) = got
  parse_ver(token_len, take_u32(xs))

def parse_header(xs: List<U32>) -> QuicLongHeader:
  parse_tok(take_u8(xs))

def frame_fields(frame: QuicLongHeader) -> U32 & U32 & U32 & U32:
  match frame:
    case QuicLongHeader{version, dcid_len, scid_len, token_len}:
      (version, dcid_len, scid_len, token_len)

def same_rest(version1: U32, dcid_len1: U32, scid_len1: U32, token_len1: U32, y: U32 & U32 & U32 & U32) -> Bool:
  (version2, dcid_len2, scid_len2, token_len2) = y
  both(both(U32.is_eq(version1, version2), U32.is_eq(dcid_len1, dcid_len2)), both(U32.is_eq(scid_len1, scid_len2), U32.is_eq(token_len1, token_len2)))

def same_left(x: U32 & U32 & U32 & U32, y: U32 & U32 & U32 & U32) -> Bool:
  (version1, dcid_len1, scid_len1, token_len1) = x
  same_rest(version1, dcid_len1, scid_len1, token_len1, y)

def same_frame(a: QuicLongHeader, b: QuicLongHeader) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
