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
