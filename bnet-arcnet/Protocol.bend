import Base

# bnet-arcnet: ArcFrame fields identify this protocol.
# SOH marker 1, broadcast DID 0, count 16.

type ArcFrame is Data:
  ArcFrame{soh: U32, sid: U32, did: U32, count: U32}

def is_soh(frame: ArcFrame) -> Bool:
  match frame:
    case ArcFrame{soh, sid, did, count}:
      U32.is_eq(soh, 1)

def label(frame: ArcFrame) -> String:
  match frame:
    case ArcFrame{soh, sid, did, count}:
      "ARCNET " ++ U32.show(soh) ++ " " ++ U32.show(did) ++ " " ++ U32.show(count)

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

# Four octets: SOH, source, destination, and count.

def build_header(frame: ArcFrame) -> List<U32>:
  match frame:
      case ArcFrame{soh, sid, did, count}:
        cat(be_u8(soh), cat(be_u8(sid), cat(be_u8(did), be_u8(count))))

def parse_count(soh: U32, sid: U32, did: U32, got: U32 & List<U32>) -> ArcFrame:
  (count, rest) = got
  ArcFrame{soh, sid, did, count}

def parse_did(soh: U32, sid: U32, got: U32 & List<U32>) -> ArcFrame:
  (did, xs) = got
  parse_count(soh, sid, did, take_u8(xs))

def parse_sid(soh: U32, got: U32 & List<U32>) -> ArcFrame:
  (sid, xs) = got
  parse_did(soh, sid, take_u8(xs))

def parse_soh(got: U32 & List<U32>) -> ArcFrame:
  (soh, xs) = got
  parse_sid(soh, take_u8(xs))

def parse_header(xs: List<U32>) -> ArcFrame:
  parse_soh(take_u8(xs))

def frame_fields(frame: ArcFrame) -> U32 & U32 & U32 & U32:
  match frame:
    case ArcFrame{soh, sid, did, count}:
      (soh, sid, did, count)

def same_rest(soh1: U32, sid1: U32, did1: U32, count1: U32, y: U32 & U32 & U32 & U32) -> Bool:
  (soh2, sid2, did2, count2) = y
  both(both(U32.is_eq(soh1, soh2), U32.is_eq(sid1, sid2)), both(U32.is_eq(did1, did2), U32.is_eq(count1, count2)))

def same_left(x: U32 & U32 & U32 & U32, y: U32 & U32 & U32 & U32) -> Bool:
  (soh1, sid1, did1, count1) = x
  same_rest(soh1, sid1, did1, count1, y)

def same_frame(a: ArcFrame, b: ArcFrame) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
