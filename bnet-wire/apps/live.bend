# Capture one packet from device any, or print why capture did not open.
# command: bend apps/live.bend
# expected stdout: a summary line, CAPTURE 0, or a libpcap or dumpcap error
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    got : Result<&1, &1, U32 & String, String> <- Net.capture("any", 1)
    IO.print(Net.result_text(got))
