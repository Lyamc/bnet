# Print the websocket label from Protocol.label.
# command: bend apps/show.bend
# expected stdout: WEBSOCKET 1 1 5 4
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.WsFrame{1, 1, 1, 5}))
