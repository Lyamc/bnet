import Base

# bnet-http: HttpRequest fields identify this protocol.
# Method 1 is GET. Version 1.1.

type HttpRequest is Data:
  HttpRequest{method: U32, major: U32, minor: U32, content_length: U32}

def post_or(is_post: Bool) -> String:
  match is_post:
    case True{}:
      "POST"
    case False{}:
      "OTHER"

def method_token(is_get: Bool, is_post: Bool) -> String:
  match is_get:
    case True{}:
      "GET"
    case False{}:
      post_or(is_post)

def is_get(req: HttpRequest) -> Bool:
  match req:
    case HttpRequest{method, major, minor, content_length}:
      U32.is_eq(method, 1)

def label(req: HttpRequest) -> String:
  match req:
    case HttpRequest{+method, major, minor, content_length}:
      "HTTP " ++ method_token(U32.is_eq(method, 1), U32.is_eq(method, 2)) ++ "/" ++ U32.show(major) ++ "." ++ U32.show(minor)

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

# Eight octets: method, major, minor, and content length.

def build_header(req: HttpRequest) -> List<U32>:
  match req:
      case HttpRequest{method, major, minor, content_length}:
        cat(be_u8(method), cat(be_u8(major), cat(be_u8(minor), cat(be_u32(content_length), be_u8(0)))))

def parse_len(method: U32, major: U32, minor: U32, got: U32 & List<U32>) -> HttpRequest:
  (content_length, rest) = got
  HttpRequest{method, major, minor, content_length}

def parse_minor(method: U32, major: U32, got: U32 & List<U32>) -> HttpRequest:
  (minor, xs) = got
  parse_len(method, major, minor, take_u32(xs))

def parse_major(method: U32, got: U32 & List<U32>) -> HttpRequest:
  (major, xs) = got
  parse_minor(method, major, take_u8(xs))

def parse_method(got: U32 & List<U32>) -> HttpRequest:
  (method, xs) = got
  parse_major(method, take_u8(xs))

def parse_header(xs: List<U32>) -> HttpRequest:
  parse_method(take_u8(xs))

def frame_fields(frame: HttpRequest) -> U32 & U32 & U32 & U32:
  match frame:
    case HttpRequest{method, major, minor, content_length}:
      (method, major, minor, content_length)

def same_rest(method1: U32, major1: U32, minor1: U32, content_length1: U32, y: U32 & U32 & U32 & U32) -> Bool:
  (method2, major2, minor2, content_length2) = y
  both(both(U32.is_eq(method1, method2), U32.is_eq(major1, major2)), both(U32.is_eq(minor1, minor2), U32.is_eq(content_length1, content_length2)))

def same_left(x: U32 & U32 & U32 & U32, y: U32 & U32 & U32 & U32) -> Bool:
  (method1, major1, minor1, content_length1) = x
  same_rest(method1, major1, minor1, content_length1, y)

def same_frame(a: HttpRequest, b: HttpRequest) -> Bool:
  same_left(frame_fields(a), frame_fields(b))
