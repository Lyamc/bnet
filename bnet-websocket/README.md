# bnet-websocket

WebSocket frames. `opcode` 1 is a text frame. `fin` 1 means this is the final fragment. A masked frame (`masked` 1) carries a 4-octet masking key. `label` prints the opcode, the FIN bit, the payload length, and the masking-key size.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`WsFrame`, `is_text`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_text`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-websocket`. Import the hyphen-free alias `bnet_websocket`:

```
import ../bnet_websocket/Protocol.bend as Net
```

Opcode 1 (text), FIN 1, payload 5, masking key 4 octets.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
WEBSOCKET 1 1 5 4
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/websocket.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
WEBSOCKET 1 1 5 4
```
