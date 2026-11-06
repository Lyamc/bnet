# Print the mqtt label from Protocol.label.
# command: bend apps/show.bend
# expected stdout: MQTT 1 0 12
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.MqttPacket{1, 0, 10}))
