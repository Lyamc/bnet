# Send one request header and print the response header.
# command: bend apps/client.bend
# expected stdout: CLIENT ETHERNET 34525 78
import Base
import ./Exchange.bend as Ex

def main() -> IO(Unit):
  Ex.demo_client()
