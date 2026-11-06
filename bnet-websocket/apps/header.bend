# Build the show fixture, parse those octets, and print the header length when the fields match.
# command: bend apps/header.bend
# expected stdout: HEADER 6
import Base
import ./../Protocol.bend as Net

def line(ok: Bool, n: U32) -> String:
  match ok:
    case True{}:
      "HEADER " ++ U32.show(n)
    case False{}:
      "MISMATCH"

def show_parsed(frame: Net.WsFrame, packed: U32 & List<U32>) -> IO(Unit):
  (n, octets) = packed
  do IO<Unit>:
    IO.print(line(Net.same_frame(frame, Net.parse_header(octets)), n))

def main() -> IO(Unit):
  show_parsed(Net.WsFrame{1, 1, 1, 5}, Net.measure(Net.build_header(Net.WsFrame{1, 1, 1, 5})))
