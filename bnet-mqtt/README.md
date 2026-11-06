# bnet-mqtt

MQTT control packets. `packet_type` 1 is CONNECT. `flags` sits in the low nibble of the first byte. `remaining_length` counts the bytes after a one-byte remaining-length field, so the packet is `remaining_length + 2` octets. `label` prints the type, the flags, and that size.

This package depends only on Bend `Base`. `show`, `check`, and `header` import `./../Protocol.bend`. `client`, `server`, and `session` import `./Exchange.bend`, which imports that same module. Nothing imports another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`MqttPacket`, `is_connect`, `label`, `build_header`, `parse_header`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_connect`
- `apps/header.bend` — builds the fixture header, parses it, and prints the length
- `apps/Exchange.bend` — shared header exchange used by the client, server, and session
- `apps/server.bend` — listens for one header and sends a reply
- `apps/client.bend` — sends one header and prints the reply
- `apps/session.bend` — runs the server and client in one process, including failures and a timeout

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-mqtt`. Import the hyphen-free alias `bnet_mqtt`:

```
import ../bnet_mqtt/Protocol.bend as Net
```

Packet type 1 (CONNECT), flags 0, remaining length 10, so the packet is 12 octets.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

The client, server, and session carry headers over Bend TCP on `127.0.0.1`. One character is one header octet.

### `bend apps/show.bend`

```
MQTT 1 0 12
```

### `bend apps/check.bend`

```
True
```

### `bend apps/header.bend`

```
HEADER 2
```

### `bend apps/server.bend`

Start this first. It listens on `127.0.0.1:19115`, parses one request header, and sends a reply header.

`BNET_MODE=bad` answers with the request header and prints `MODE bad`. `BNET_MODE=reset` accepts and closes, and prints `MODE reset`. `BNET_MODE=silent` reads the request and does not answer, and prints `MODE silent`.

```
SERVER MQTT 1 0 12
```

### `bend apps/client.bend`

Connects to that server, sends the show fixture, and prints the reply. A failed exchange prints `ERROR refused`, `ERROR closed`, `ERROR value`, or `ERROR timeout`.

```
CLIENT MQTT 2 0 4
```

### `bend apps/session.bend`

Starts a local server in the same process, connects, and exchanges two headers. Then it checks a wrong reply, a peer that closes, a peer that never answers, and a port with no server.

```
CONNECT
OK MQTT 2 0 4
OK MQTT 2 0 4
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

`imports/mqtt.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
MQTT 1 0 12
```
