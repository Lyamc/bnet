# Import bnet-modbus-tcp through the hyphen-free alias and print Protocol.label.
# command: bend imports/modbus-tcp.bend
# expected stdout: MODBUS_TCP 0 3 12
import Base
import ../bnet_modbus_tcp/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.TcpMbap{1, 0, 6, 1, 3}))
