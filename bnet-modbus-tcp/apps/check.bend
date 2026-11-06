# Print the modbus-tcp predicate is_modbus.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_modbus(Net.TcpMbap{1, 0, 6, 1, 3})))
