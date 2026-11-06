# Print the ipv4 label from Protocol.label.
# command: bend apps/show.bend
# expected stdout: IPV4 4 6 20
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.Ipv4Header{4, 5, 40, 6, 0}))
