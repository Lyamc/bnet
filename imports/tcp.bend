# Import bnet-tcp through the hyphen-free alias and print Protocol.label.
# command: bend imports/tcp.bend
# expected stdout: TCP 54321 443 2 20
import Base
import ../bnet_tcp/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.TcpSegment{54321, 443, 1000, 2, 65535, 5}))
