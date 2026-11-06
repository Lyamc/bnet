# bnet-modbus-tcp

Modbus TCP MBAP headers. `protocol_id` is 0 for Modbus. `length` counts the bytes after the length field, so the ADU is `length + 6` octets (transaction id, protocol id, and the length field itself). `label` prints the protocol id, the function, and that ADU size.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`TcpMbap`, `is_modbus`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_modbus`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-modbus-tcp`. Import the hyphen-free alias `bnet_modbus_tcp`:

```
import ../bnet_modbus_tcp/Protocol.bend as Net
```

Protocol id 0, function 3, length 6, so the ADU is 12 octets.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
MODBUS_TCP 0 3 12
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/modbus-tcp.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
MODBUS_TCP 0 3 12
```
