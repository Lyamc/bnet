# Connect to a local server, exchange two headers, then exercise
# a wrong reply, a reset, a silent timeout, and a refused port.
# command: bend apps/session.bend
# expected stdout:
# CONNECT
# OK MODBUS_RTU 16 1
# OK MODBUS_RTU 16 1
# CONNECT
# ERROR value
# CONNECT
# ERROR closed
# CONNECT
# RETRY
# RETRY
# ERROR timeout
# ERROR refused
import Base
import ./Exchange.bend as Ex

def main() -> IO(Unit):
  Ex.session_main()
