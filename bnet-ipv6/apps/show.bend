# Print the ipv6 label from Protocol.label.
# command: bend apps/show.bend
# expected stdout: IPV6 6 17 72
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.Ipv6Header{6, 32, 17, 64}))
