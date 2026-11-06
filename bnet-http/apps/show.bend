# Print the http label from Protocol.label.
# command: bend apps/show.bend
# expected stdout: HTTP GET/1.1
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.HttpRequest{1, 1, 1, 0}))
