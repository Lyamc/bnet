# Print the summary of the sample Ethernet frame.
# command: bend apps/show.bend
# expected stdout: 1 60 60 EN10MB 2048
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.summary(Net.Packet{1, 60, 60, 1, 2048}))
