# Print the ethernet label from Protocol.label.
# command: bend apps/show.bend
# expected stdout: ETHERNET 2048 78
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.EtherFrame{170, 187, 2048, 64}))
