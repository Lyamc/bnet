# Print the arcnet predicate is_soh.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_soh(Net.ArcFrame{1, 5, 0, 16})))
