# Print the udp predicate is_dns_port.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_dns_port(Net.UdpDatagram{40534, 53, 28, 0})))
