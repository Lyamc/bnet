# Print the mqtt predicate is_connect.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_connect(Net.MqttPacket{1, 0, 10})))
