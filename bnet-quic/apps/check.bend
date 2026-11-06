# Print the quic predicate is_version_1.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_version_1(Net.QuicLongHeader{1, 8, 8, 0})))
