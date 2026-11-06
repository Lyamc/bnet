# bnet-modbus-tcp

Modbus TCP MBAP headers. `protocol_id` is 0 for Modbus. `length` counts the bytes after the length field, so the ADU is `length + 6` octets (transaction id, protocol id, and the length field itself). `label` prints the protocol id, the function, and that ADU size.

This package depends only on Bend `Base`. `show`, `check`, and `header` import `./../Protocol.bend`. `client`, `server`, and `session` import `./Exchange.bend`, which imports that same module. Nothing imports another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`TcpMbap`, `is_modbus`, `label`, `build_header`, `parse_header`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_modbus`
- `apps/header.bend` — builds the fixture header, parses it, and prints the length
- `apps/Exchange.bend` — shared header exchange used by the client, server, and session
- `apps/server.bend` — listens for one header and sends a reply
- `apps/client.bend` — sends one header and prints the reply
- `apps/session.bend` — runs the server and client in one process, including failures and a timeout

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-modbus-tcp`. Import the hyphen-free alias `bnet_modbus_tcp`:

```
import ../bnet_modbus_tcp/Protocol.bend as Net
```

Protocol id 0, function 3, length 6, so the ADU is 12 octets.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

The client, server, and session carry headers over Bend TCP on `127.0.0.1`. One character is one header octet.

### `bend apps/show.bend`

```
MODBUS_TCP 0 3 12
```

### `bend apps/check.bend`

```
True
```

### `bend apps/header.bend`

```
HEADER 7
```

### `bend apps/server.bend`

Start this first. It listens on `127.0.0.1:19104`, parses one request header, and sends a reply header.

`BNET_MODE=bad` answers with the request header and prints `MODE bad`. `BNET_MODE=reset` accepts and closes, and prints `MODE reset`. `BNET_MODE=silent` reads the request and does not answer, and prints `MODE silent`.

```
SERVER MODBUS_TCP 0 3 12
```

### `bend apps/client.bend`

Connects to that server, sends the show fixture, and prints the reply. A failed exchange prints `ERROR refused`, `ERROR closed`, `ERROR value`, or `ERROR timeout`.

```
CLIENT MODBUS_TCP 0 16 12
```

### `bend apps/session.bend`

Starts a local server in the same process, connects, and exchanges two headers. Then it checks a wrong reply, a peer that closes, a peer that never answers, and a port with no server.

```
CONNECT
OK MODBUS_TCP 0 16 12
OK MODBUS_TCP 0 16 12
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

`imports/modbus-tcp.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
MODBUS_TCP 0 3 12
```
