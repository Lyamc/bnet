# Print the bacnet predicate is_bacnet_ip.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_bacnet_ip(Net.BvlcHeader{129, 10, 24})))
