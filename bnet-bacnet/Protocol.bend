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
