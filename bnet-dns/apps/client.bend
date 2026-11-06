# Send one request header and print the response header.
# command: bend apps/client.bend
# expected stdout: CLIENT DNS 32768 1 1
import Base
import ./Exchange.bend as Ex

def main() -> IO(Unit):
  Ex.demo_client()
