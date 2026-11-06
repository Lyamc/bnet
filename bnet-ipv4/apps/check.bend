# Print the ipv4 predicate is_version_4.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_version_4(Net.Ipv4Header{4, 5, 40, 6, 0})))
