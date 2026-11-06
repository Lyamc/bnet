import Base

# bnet-modbus-rtu: RtuAdu fields identify this protocol.
# Function 3 (Read Holding Registers) and CRC 4660.

type RtuAdu is Data:
  RtuAdu{slave: U32, function: U32, start_addr: U32, quantity: U32, crc: U32}

def is_read_holding(adu: RtuAdu) -> Bool:
  match adu:
    case RtuAdu{slave, function, start_addr, quantity, crc}:
      U32.is_eq(function, 3)

def label(adu: RtuAdu) -> String:
  match adu:
    case RtuAdu{slave, function, start_addr, quantity, crc}:
      "MODBUS_RTU " ++ U32.show(function) ++ " " ++ U32.show(crc)
