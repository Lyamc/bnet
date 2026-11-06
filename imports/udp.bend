# Import bnet-udp through the hyphen-free alias and print Protocol.label.
# command: bend imports/udp.bend
# expected stdout: UDP 40534 53 20
import Base
import ../bnet_udp/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.UdpDatagram{40534, 53, 28, 0}))
