# Print the modbus-rtu label from Protocol.label.
# command: bend apps/show.bend
# expected stdout: MODBUS_RTU 3 4660
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.RtuAdu{1, 3, 0, 10, 4660}))
