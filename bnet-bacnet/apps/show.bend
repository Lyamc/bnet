# Print the bacnet label from Protocol.label.
# command: bend apps/show.bend
# expected stdout: BACNET 129 10 20
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.BvlcHeader{129, 10, 24}))
