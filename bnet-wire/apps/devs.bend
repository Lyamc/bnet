# List capture devices through libpcap. Names depend on this machine.
# command: bend apps/devs.bend
# expected stdout: one device name per line, or none, or a libpcap error
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    got : Result<&1, &1, U32 & String, String> <- Net.list_devs()
    IO.print(Net.result_text(got))
