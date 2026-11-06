# Import bnet-ipv4 through the hyphen-free alias and print Protocol.label.
# command: bend imports/ipv4.bend
# expected stdout: IPV4 4 6 20
import Base
import ../bnet_ipv4/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.Ipv4Header{4, 5, 40, 6, 0}))
