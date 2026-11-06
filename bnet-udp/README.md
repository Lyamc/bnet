# bnet-udp

UDP datagrams. The header is 8 octets and `length` includes it, so the payload is `length - 8`. `label` prints the source port, the destination port, and that payload size. The fixture is port 40534 to port 53.

This package depends only on Bend `Base`. `show`, `check`, and `header` import `./../Protocol.bend`. `client`, `server`, and `session` import `./Exchange.bend`, which imports that same module. Nothing imports another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`UdpDatagram`, `is_dns_port`, `label`, `build_header`, `parse_header`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_dns_port`
- `apps/header.bend` — builds the fixture header, parses it, and prints the length
- `apps/Exchange.bend` — shared header exchange used by the client, server, and session
- `apps/server.bend` — listens for one header and sends a reply
- `apps/client.bend` — sends one header and prints the reply
- `apps/session.bend` — runs the server and client in one process, including failures and a timeout

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-udp`. Import the hyphen-free alias `bnet_udp`:

```
import ../bnet_udp/Protocol.bend as Net
```

Port pair 40534 to 53. Length 28 includes the 8-octet header, so the payload is 20.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

The client, server, and session carry headers over Bend TCP on `127.0.0.1`. One character is one header octet.

### `bend apps/show.bend`

```
UDP 40534 53 20
```

### `bend apps/check.bend`

```
True
```

### `bend apps/header.bend`

```
HEADER 8
```

### `bend apps/server.bend`

Start this first. It listens on `127.0.0.1:19110`, parses one request header, and sends a reply header.

`BNET_MODE=bad` answers with the request header and prints `MODE bad`. `BNET_MODE=reset` accepts and closes, and prints `MODE reset`. `BNET_MODE=silent` reads the request and does not answer, and prints `MODE silent`.

```
SERVER UDP 40534 53 20
```

### `bend apps/client.bend`

Connects to that server, sends the show fixture, and prints the reply. A failed exchange prints `ERROR refused`, `ERROR closed`, `ERROR value`, or `ERROR timeout`.

```
CLIENT UDP 53 40534 12
```

### `bend apps/session.bend`

Starts a local server in the same process, connects, and exchanges two headers. Then it checks a wrong reply, a peer that closes, a peer that never answers, and a port with no server.

```
CONNECT
OK UDP 53 40534 12
OK UDP 53 40534 12
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

`imports/udp.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
UDP 40534 53 20
```
