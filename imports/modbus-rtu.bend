# Import bnet-modbus-rtu through the hyphen-free alias and print Protocol.label.
# command: bend imports/modbus-rtu.bend
# expected stdout: MODBUS_RTU 3 4660
import Base
import ../bnet_modbus_rtu/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.RtuAdu{1, 3, 0, 10, 4660}))
