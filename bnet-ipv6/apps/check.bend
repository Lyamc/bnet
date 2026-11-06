# Print the ipv6 predicate is_version_6.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_version_6(Net.Ipv6Header{6, 32, 17, 64})))
