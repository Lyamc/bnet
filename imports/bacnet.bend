# Import bnet-bacnet through the hyphen-free alias and print Protocol.label.
# command: bend imports/bacnet.bend
# expected stdout: BACNET 129 10 20
import Base
import ../bnet_bacnet/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.BvlcHeader{129, 10, 24}))
