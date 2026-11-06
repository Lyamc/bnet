# bnet-quic

QUIC long-header fields. `version` 1 is QUIC version 1 (0x00000001). Connection-id octets are `dcid_len + scid_len`. `label` prints the version, that sum, and `token_len`.

This package depends only on Bend `Base`. `show`, `check`, and `header` import `./../Protocol.bend`. `client`, `server`, and `session` import `./Exchange.bend`, which imports that same module. Nothing imports another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`QuicLongHeader`, `is_version_1`, `label`, `build_header`, `parse_header`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_version_1`
- `apps/header.bend` — builds the fixture header, parses it, and prints the length
- `apps/Exchange.bend` — shared header exchange used by the client, server, and session
- `apps/server.bend` — listens for one header and sends a reply
- `apps/client.bend` — sends one header and prints the reply
- `apps/session.bend` — runs the server and client in one process, including failures and a timeout

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-quic`. Import the hyphen-free alias `bnet_quic`:

```
import ../bnet_quic/Protocol.bend as Net
```

Version 1. DCID 8 plus SCID 8 is 16 octets. Token length 0.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

The client, server, and session carry headers over Bend TCP on `127.0.0.1`. One character is one header octet.

### `bend apps/show.bend`

```
QUIC 1 16 0
```

### `bend apps/check.bend`

```
True
```

### `bend apps/header.bend`

```
HEADER 23
```

### `bend apps/server.bend`

Start this first. It listens on `127.0.0.1:19108`, parses one request header, and sends a reply header.

`BNET_MODE=bad` answers with the request header and prints `MODE bad`. `BNET_MODE=reset` accepts and closes, and prints `MODE reset`. `BNET_MODE=silent` reads the request and does not answer, and prints `MODE silent`.

```
SERVER QUIC 1 16 0
```

### `bend apps/client.bend`

Connects to that server, sends the show fixture, and prints the reply. A failed exchange prints `ERROR refused`, `ERROR closed`, `ERROR value`, or `ERROR timeout`.

```
CLIENT QUIC 1 8 0
```

### `bend apps/session.bend`

Starts a local server in the same process, connects, and exchanges two headers. Then it checks a wrong reply, a peer that closes, a peer that never answers, and a port with no server.

```
CONNECT
OK QUIC 1 8 0
OK QUIC 1 8 0
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

`imports/quic.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
QUIC 1 16 0
```
