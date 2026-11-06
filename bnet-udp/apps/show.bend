# Print the udp label from Protocol.label.
# command: bend apps/show.bend
# expected stdout: UDP 40534 53 20
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.UdpDatagram{40534, 53, 28, 0}))
