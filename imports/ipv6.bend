# Import bnet-ipv6 through the hyphen-free alias and print Protocol.label.
# command: bend imports/ipv6.bend
# expected stdout: IPV6 6 17 72
import Base
import ../bnet_ipv6/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.Ipv6Header{6, 32, 17, 64}))
