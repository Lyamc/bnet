# Import bnet-ethernet through the hyphen-free alias and print Protocol.label.
# command: bend imports/ethernet.bend
# expected stdout: ETHERNET 2048 78
import Base
import ../bnet_ethernet/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.EtherFrame{170, 187, 2048, 64}))
