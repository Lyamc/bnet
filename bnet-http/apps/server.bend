# Listen for one request header and answer with a response header.
# command: bend apps/server.bend
# expected stdout: SERVER HTTP GET/1.1
# BNET_MODE=bad answers with the request header.
# BNET_MODE=reset accepts and closes.
# BNET_MODE=silent accepts, reads, and does not answer.
import Base
import ./Exchange.bend as Ex

def main() -> IO(Unit):
  do IO<Unit>:
    got : Result<&1, &1, U32 & String, String> <- IO.get_env("BNET_MODE")
    Ex.on_env(got)
