# bnet-ipv6

IPv6 headers. `version` is 6. The fixed header is 40 octets, so a datagram is 40 plus `payload_length`. `next_header` 17 is UDP. `label` prints version, next header, and that datagram size.

This package depends only on Bend `Base`. `show`, `check`, and `header` import `./../Protocol.bend`. `client`, `server`, and `session` import `./Exchange.bend`, which imports that same module. Nothing imports another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`Ipv6Header`, `is_version_6`, `label`, `build_header`, `parse_header`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_version_6`
- `apps/header.bend` — builds the fixture header, parses it, and prints the length
- `apps/Exchange.bend` — shared header exchange used by the client, server, and session
- `apps/server.bend` — listens for one header and sends a reply
- `apps/client.bend` — sends one header and prints the reply
- `apps/session.bend` — runs the server and client in one process, including failures and a timeout

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-ipv6`. Import the hyphen-free alias `bnet_ipv6`:

```
import ../bnet_ipv6/Protocol.bend as Net
```

Version 6, next header 17 (UDP), payload 32, so 40 + 32 = 72 octets.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

The client, server, and session carry headers over Bend TCP on `127.0.0.1`. One character is one header octet.

### `bend apps/show.bend`

```
IPV6 6 17 72
```

### `bend apps/check.bend`

```
True
```

### `bend apps/header.bend`

```
HEADER 40
```

### `bend apps/server.bend`

Start this first. It listens on `127.0.0.1:19102`, parses one request header, and sends a reply header.

`BNET_MODE=bad` answers with the request header and prints `MODE bad`. `BNET_MODE=reset` accepts and closes, and prints `MODE reset`. `BNET_MODE=silent` reads the request and does not answer, and prints `MODE silent`.

```
SERVER IPV6 6 17 72
```

### `bend apps/client.bend`

Connects to that server, sends the show fixture, and prints the reply. A failed exchange prints `ERROR refused`, `ERROR closed`, `ERROR value`, or `ERROR timeout`.

```
CLIENT IPV6 6 6 40
```

### `bend apps/session.bend`

Starts a local server in the same process, connects, and exchanges two headers. Then it checks a wrong reply, a peer that closes, a peer that never answers, and a port with no server.

```
CONNECT
OK IPV6 6 6 40
OK IPV6 6 6 40
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

`imports/ipv6.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
IPV6 6 17 72
```
