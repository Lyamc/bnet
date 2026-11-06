# Import bnet-websocket through the hyphen-free alias and print Protocol.label.
# command: bend imports/websocket.bend
# expected stdout: WEBSOCKET 1 1 5 4
import Base
import ../bnet_websocket/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.WsFrame{1, 1, 1, 5}))
