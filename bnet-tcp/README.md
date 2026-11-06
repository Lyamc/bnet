# bnet-tcp

TCP segments. `flags` bit 2 (0x02) is SYN. `data_offset` counts 32-bit words, so the header is `data_offset * 4` octets. `label` prints the source port, the destination port, the flags, and that header size. The fixture is port 54321 to port 443.

This package depends only on Bend `Base`. `show`, `check`, and `header` import `./../Protocol.bend`. `client`, `server`, and `session` import `./Exchange.bend`, which imports that same module. Nothing imports another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`TcpSegment`, `is_syn`, `label`, `build_header`, `parse_header`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_syn`
- `apps/header.bend` — builds the fixture header, parses it, and prints the length
- `apps/Exchange.bend` — shared header exchange used by the client, server, and session
- `apps/server.bend` — listens for one header and sends a reply
- `apps/client.bend` — sends one header and prints the reply
- `apps/session.bend` — runs the server and client in one process, including failures and a timeout

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-tcp`. Import the hyphen-free alias `bnet_tcp`:

```
import ../bnet_tcp/Protocol.bend as Net
```

Port pair 54321 to 443. Flags 2 is SYN. Data offset 5 is a 20-octet header.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

The client, server, and session carry headers over Bend TCP on `127.0.0.1`. One character is one header octet.

### `bend apps/show.bend`

```
TCP 54321 443 2 20
```

### `bend apps/check.bend`

```
True
```

### `bend apps/header.bend`

```
HEADER 20
```

### `bend apps/server.bend`

Start this first. It listens on `127.0.0.1:19111`, parses one request header, and sends a reply header.

`BNET_MODE=bad` answers with the request header and prints `MODE bad`. `BNET_MODE=reset` accepts and closes, and prints `MODE reset`. `BNET_MODE=silent` reads the request and does not answer, and prints `MODE silent`.

```
SERVER TCP 54321 443 2 20
```

### `bend apps/client.bend`

Connects to that server, sends the show fixture, and prints the reply. A failed exchange prints `ERROR refused`, `ERROR closed`, `ERROR value`, or `ERROR timeout`.

```
CLIENT TCP 443 54321 18 20
```

### `bend apps/session.bend`

Starts a local server in the same process, connects, and exchanges two headers. Then it checks a wrong reply, a peer that closes, a peer that never answers, and a port with no server.

```
CONNECT
OK TCP 443 54321 18 20
OK TCP 443 54321 18 20
CONNECT
ERROR value
CONNECT
ERROR closed
CONNECT
RETRY
RETRY
ERROR timeout
ERROR refused
```

## Outside import

`imports/tcp.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
TCP 54321 443 2 20
```
