# Import bnet-quic through the hyphen-free alias and print Protocol.label.
# command: bend imports/quic.bend
# expected stdout: QUIC 1 16 0
import Base
import ../bnet_quic/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.QuicLongHeader{1, 8, 8, 0}))
