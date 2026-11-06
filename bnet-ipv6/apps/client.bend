# Send one request header and print the response header.
# command: bend apps/client.bend
# expected stdout: CLIENT IPV6 6 6 40
import Base
import ./Exchange.bend as Ex

def main() -> IO(Unit):
  Ex.demo_client()
