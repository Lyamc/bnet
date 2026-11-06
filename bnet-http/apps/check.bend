# Print the http predicate is_get.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_get(Net.HttpRequest{1, 1, 1, 0})))
