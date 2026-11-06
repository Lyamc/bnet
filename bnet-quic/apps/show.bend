# Print the quic label from Protocol.label.
# command: bend apps/show.bend
# expected stdout: QUIC 1 16 0
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.QuicLongHeader{1, 8, 8, 0}))
