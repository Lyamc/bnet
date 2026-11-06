# Import bnet-arp through the hyphen-free alias and print Protocol.label.
# command: bend imports/arp.bend
# expected stdout: ARP 1 2048 6 4
import Base
import ../bnet_arp/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.ArpMessage{1, 2048, 6, 4, 1}))
