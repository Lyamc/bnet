# Build the show fixture, parse those octets, and print the header length when the fields match.
# command: bend apps/header.bend
# expected stdout: HEADER 5
import Base
import ./../Protocol.bend as Net

def line(ok: Bool, n: U32) -> String:
  match ok:
    case True{}:
      "HEADER " ++ U32.show(n)
    case False{}:
      "MISMATCH"

def show_parsed(frame: Net.TlsRecord, packed: U32 & List<U32>) -> IO(Unit):
  (n, octets) = packed
  do IO<Unit>:
    IO.print(line(Net.same_frame(frame, Net.parse_header(octets)), n))

def main() -> IO(Unit):
  show_parsed(Net.TlsRecord{22, 3, 3, 40}, Net.measure(Net.build_header(Net.TlsRecord{22, 3, 3, 40})))
