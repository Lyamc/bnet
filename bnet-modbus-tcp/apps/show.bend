# Print the modbus-tcp label from Protocol.label.
# command: bend apps/show.bend
# expected stdout: MODBUS_TCP 0 3 12
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.TcpMbap{1, 0, 6, 1, 3}))
