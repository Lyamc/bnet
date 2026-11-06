import Base

# bnet-tcp: TcpSegment fields identify this protocol.
# Port pair 54321 to 443. Flags 2 is SYN. Data offset 5 is a 20-octet header.

type TcpSegment is Data:
  TcpSegment{src_port: U32, dst_port: U32, seq: U32, flags: U32, window: U32, data_offset: U32}

def is_syn(seg: TcpSegment) -> Bool:
  match seg:
    case TcpSegment{src_port, dst_port, seq, flags, window, data_offset}:
      U32.is_eq((flags .&. 2 : U32), 2)

def label(seg: TcpSegment) -> String:
  match seg:
    case TcpSegment{src_port, dst_port, seq, flags, window, data_offset}:
      "TCP " ++ U32.show(src_port) ++ " " ++ U32.show(dst_port) ++ " " ++ U32.show(flags) ++ " " ++ U32.show((data_offset * 4 : U32))
