# Print the websocket predicate is_text.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_text(Net.WsFrame{1, 1, 1, 5})))
