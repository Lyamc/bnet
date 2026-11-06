# bnet-modbus-rtu

Modbus RTU application data units. `function` 3 is Read Holding Registers. `crc` is the RTU checksum (Modbus TCP has none; it uses an MBAP header instead). `label` prints the function and the CRC.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`RtuAdu`, `is_read_holding`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_read_holding`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-modbus-rtu`. Import the hyphen-free alias `bnet_modbus_rtu`:

```
import ../bnet_modbus_rtu/Protocol.bend as Net
```

Function 3 (Read Holding Registers) and CRC 4660.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
MODBUS_RTU 3 4660
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/modbus-rtu.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
MODBUS_RTU 3 4660
```
