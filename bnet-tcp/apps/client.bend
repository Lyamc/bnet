# Send one request header and print the response header.
# command: bend apps/client.bend
# expected stdout: CLIENT TCP 443 54321 18 20
import Base
import ./Exchange.bend as Ex

def main() -> IO(Unit):
  Ex.demo_client()
