# Send one request header and print the response header.
# command: bend apps/client.bend
# expected stdout: CLIENT IPV4 4 17 20
import Base
import ./Exchange.bend as Ex

def main() -> IO(Unit):
  Ex.demo_client()
