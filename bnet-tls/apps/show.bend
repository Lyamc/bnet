# Print the tls label from Protocol.label.
# command: bend apps/show.bend
# expected stdout: TLS 22 3.3 45
import Base
import ./../Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.TlsRecord{22, 3, 3, 40}))
