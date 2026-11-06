# Import bnet-tls through the hyphen-free alias and print Protocol.label.
# command: bend imports/tls.bend
# expected stdout: TLS 22 3.3 45
import Base
import ../bnet_tls/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.TlsRecord{22, 3, 3, 40}))
