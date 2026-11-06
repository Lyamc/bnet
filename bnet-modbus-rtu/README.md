# bnet-modbus-rtu

Modbus RTU application data units. `function` 3 is Read Holding Registers. `crc` is the RTU checksum (Modbus TCP has none; it uses an MBAP header instead). `label` prints the function and the CRC.

This package depends only on Bend `Base`. `show`, `check`, and `header` import `./../Protocol.bend`. `client`, `server`, and `session` import `./Exchange.bend`, which imports that same module. Nothing imports another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`RtuAdu`, `is_read_holding`, `label`, `build_header`, `parse_header`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_read_holding`
- `apps/header.bend` — builds the fixture header, parses it, and prints the length
- `apps/Exchange.bend` — shared header exchange used by the client, server, and session
- `apps/server.bend` — listens for one header and sends a reply
- `apps/client.bend` — sends one header and prints the reply
- `apps/session.bend` — runs the server and client in one process, including failures and a timeout

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-modbus-rtu`. Import the hyphen-free alias `bnet_modbus_rtu`:

```
import ../bnet_modbus_rtu/Protocol.bend as Net
```

Function 3 (Read Holding Registers) and CRC 4660.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

The client, server, and session carry headers over Bend TCP on `127.0.0.1`. One character is one header octet.

### `bend apps/show.bend`

```
MODBUS_RTU 3 4660
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

Start this first. It listens on `127.0.0.1:19103`, parses one request header, and sends a reply header.

`BNET_MODE=bad` answers with the request header and prints `MODE bad`. `BNET_MODE=reset` accepts and closes, and prints `MODE reset`. `BNET_MODE=silent` reads the request and does not answer, and prints `MODE silent`.

```
SERVER MODBUS_RTU 3 4660
```

### `bend apps/client.bend`

Connects to that server, sends the show fixture, and prints the reply. A failed exchange prints `ERROR refused`, `ERROR closed`, `ERROR value`, or `ERROR timeout`.

```
CLIENT MODBUS_RTU 16 1
```

### `bend apps/session.bend`

Starts a local server in the same process, connects, and exchanges two headers. Then it checks a wrong reply, a peer that closes, a peer that never answers, and a port with no server.

```
CONNECT
OK MODBUS_RTU 16 1
OK MODBUS_RTU 16 1
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

`imports/modbus-rtu.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
MODBUS_RTU 3 4660
```
