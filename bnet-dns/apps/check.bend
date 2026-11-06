# Print the dns predicate is_query.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_query(Net.DnsMessage{4660, 0, 1, 1})))
