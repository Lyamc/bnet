# Print the modbus-rtu predicate is_read_holding.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_read_holding(Net.RtuAdu{1, 3, 0, 10, 4660})))
