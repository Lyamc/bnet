# Import bnet-wire through the hyphen-free alias and print Protocol.summary.
# command: bend imports/wire.bend
# expected stdout: 1 60 60 EN10MB 2048
import Base
import ../bnet_wire/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.summary(Net.Packet{1, 60, 60, 1, 2048}))
