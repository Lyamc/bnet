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
