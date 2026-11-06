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
