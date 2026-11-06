# Import bnet-mqtt through the hyphen-free alias and print Protocol.label.
# command: bend imports/mqtt.bend
# expected stdout: MQTT 1 0 12
import Base
import ../bnet_mqtt/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.MqttPacket{1, 0, 10}))
