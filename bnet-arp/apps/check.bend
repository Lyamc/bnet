# Print the arp predicate is_request.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_request(Net.ArpMessage{1, 2048, 6, 4, 1})))
