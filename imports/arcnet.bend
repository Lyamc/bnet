# Import bnet-arcnet through the hyphen-free alias and print Protocol.label.
# command: bend imports/arcnet.bend
# expected stdout: ARCNET 1 0 16
import Base
import ../bnet_arcnet/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.ArcFrame{1, 5, 0, 16}))
