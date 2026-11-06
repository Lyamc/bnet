# bnet-ethernet

Ethernet II frames. `ethertype` is the 16-bit EtherType. 2048 (0x0800) means the payload is IPv4. The header in front of the payload is 14 octets, so `label` reports that EtherType and the header plus `payload_len`.

This package depends only on Bend `Base`. `show`, `check`, and `header` import `./../Protocol.bend`. `client`, `server`, and `session` import `./Exchange.bend`, which imports that same module. Nothing imports another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`EtherFrame`, `is_ipv4`, `label`, `build_header`, `parse_header`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_ipv4`
- `apps/header.bend` — builds the fixture header, parses it, and prints the length
- `apps/Exchange.bend` — shared header exchange used by the client, server, and session
- `apps/server.bend` — listens for one header and sends a reply
- `apps/client.bend` — sends one header and prints the reply
- `apps/session.bend` — runs the server and client in one process, including failures and a timeout

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-ethernet`. Import the hyphen-free alias `bnet_ethernet`:

```
import ../bnet_ethernet/Protocol.bend as Net
```

EtherType 2048 is IPv4. 14 + 64 = 78 octets of header plus payload.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

The client, server, and session carry headers over Bend TCP on `127.0.0.1`. One character is one header octet.

### `bend apps/show.bend`

```
ETHERNET 2048 78
```

### `bend apps/check.bend`

```
True
```

### `bend apps/header.bend`

```
HEADER 14
```

### `bend apps/server.bend`

Start this first. It listens on `127.0.0.1:19100`, parses one request header, and sends a reply header.

`BNET_MODE=bad` answers with the request header and prints `MODE bad`. `BNET_MODE=reset` accepts and closes, and prints `MODE reset`. `BNET_MODE=silent` reads the request and does not answer, and prints `MODE silent`.

```
SERVER ETHERNET 2048 78
```

### `bend apps/client.bend`

Connects to that server, sends the show fixture, and prints the reply. A failed exchange prints `ERROR refused`, `ERROR closed`, `ERROR value`, or `ERROR timeout`.

```
CLIENT ETHERNET 34525 78
```

### `bend apps/session.bend`

Starts a local server in the same process, connects, and exchanges two headers. Then it checks a wrong reply, a peer that closes, a peer that never answers, and a port with no server.

```
CONNECT
OK ETHERNET 34525 78
OK ETHERNET 34525 78
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

`imports/ethernet.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
ETHERNET 2048 78
```
