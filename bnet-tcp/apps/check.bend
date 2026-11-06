# Print the tcp predicate is_syn.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_syn(Net.TcpSegment{54321, 443, 1000, 2, 65535, 5})))
