# Build the show fixture, parse those octets, and print the header length when the fields match.
# command: bend apps/header.bend
# expected stdout: HEADER 8
import Base
import ./../Protocol.bend as Net

def line(ok: Bool, n: U32) -> String:
  match ok:
    case True{}:
      "HEADER " ++ U32.show(n)
    case False{}:
      "MISMATCH"

def show_parsed(frame: Net.RtuAdu, packed: U32 & List<U32>) -> IO(Unit):
  (n, octets) = packed
  do IO<Unit>:
    IO.print(line(Net.same_frame(frame, Net.parse_header(octets)), n))

def main() -> IO(Unit):
  show_parsed(Net.RtuAdu{1, 3, 0, 10, 4660}, Net.measure(Net.build_header(Net.RtuAdu{1, 3, 0, 10, 4660})))
