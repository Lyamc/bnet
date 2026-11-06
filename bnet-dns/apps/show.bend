# Print the dns label from Protocol.label.
# command: bend apps/show.bend
# expected stdout: DNS 0 1 1
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.DnsMessage{4660, 0, 1, 1}))
