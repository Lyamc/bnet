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
