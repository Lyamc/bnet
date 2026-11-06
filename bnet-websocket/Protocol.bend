import Base

# bnet-websocket: WsFrame fields identify this protocol.
# Opcode 1 (text), FIN 1, payload 5, masking key 4 octets.

type WsFrame is Data:
  WsFrame{fin: U32, opcode: U32, masked: U32, payload_len: U32}

def mask_len(is_masked: Bool) -> U32:
  match is_masked:
    case True{}:
      4
    case False{}:
      0

def is_text(frame: WsFrame) -> Bool:
  match frame:
    case WsFrame{fin, opcode, masked, payload_len}:
      U32.is_eq(opcode, 1)

def label(frame: WsFrame) -> String:
  match frame:
    case WsFrame{fin, opcode, masked, payload_len}:
      "WEBSOCKET " ++ U32.show(opcode) ++ " " ++ U32.show(fin) ++ " " ++ U32.show(payload_len) ++ " " ++ U32.show(mask_len(U32.is_eq(masked, 1)))
