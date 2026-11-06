# Print the ethernet predicate is_ipv4.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_ipv4(Net.EtherFrame{170, 187, 2048, 64})))
