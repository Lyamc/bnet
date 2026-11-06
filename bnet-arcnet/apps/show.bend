# Print the arcnet label from Protocol.label.
# command: bend apps/show.bend
# expected stdout: ARCNET 1 0 16
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.ArcFrame{1, 5, 0, 16}))
