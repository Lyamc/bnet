# Import bnet-http through the hyphen-free alias and print Protocol.label.
# command: bend imports/http.bend
# expected stdout: HTTP GET/1.1
import Base
import ../bnet_http/Protocol.bend as Net

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Net.label(Net.HttpRequest{1, 1, 1, 0}))
