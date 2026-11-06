import Base

# bnet-modbus-tcp: TcpMbap fields identify this protocol.
# Protocol id 0, function 3, length 6, so the ADU is 12 octets.

type TcpMbap is Data:
  TcpMbap{transaction_id: U32, protocol_id: U32, length: U32, unit_id: U32, function: U32}

def is_modbus(mbap: TcpMbap) -> Bool:
  match mbap:
    case TcpMbap{transaction_id, protocol_id, length, unit_id, function}:
      U32.is_eq(protocol_id, 0)

def label(mbap: TcpMbap) -> String:
  match mbap:
    case TcpMbap{transaction_id, protocol_id, length, unit_id, function}:
      "MODBUS_TCP " ++ U32.show(protocol_id) ++ " " ++ U32.show(function) ++ " " ++ U32.show((length + 6 : U32))
