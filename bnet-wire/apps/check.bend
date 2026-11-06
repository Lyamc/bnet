# Print whether the sample frame is Ethernet (link type 1).
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_ethernet(Net.Packet{1, 60, 60, 1, 2048})))
