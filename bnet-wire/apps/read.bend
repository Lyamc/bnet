# Load fixtures/one.pcap through libpcap and print one summary line.
# command: bend apps/read.bend
# expected stdout: 1 60 60 EN10MB 2048
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    got : Result<&1, &1, U32 & String, String> <- Net.load_file("fixtures/one.pcap", 8)
    IO.print(Net.result_text(got))
