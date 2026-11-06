# Print the tls predicate is_handshake.
# command: bend apps/check.bend
# expected stdout: True
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Bool.show(Net.is_handshake(Net.TlsRecord{22, 3, 3, 40})))
