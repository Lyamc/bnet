# bnet-bacnet

BACnet/IP BVLC headers. `bvlc_type` 129 (0x81) is BACnet/IP. `bvlc_function` 10 (0x0A) is Original-Unicast-NPDU. The BVLC header is 4 octets, so the rest of the message is `length - 4`. `label` prints the type, the function, and that remainder.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`BvlcHeader`, `is_bacnet_ip`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_bacnet_ip`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-bacnet`. Import the hyphen-free alias `bnet_bacnet`:

```
import ../bnet_bacnet/Protocol.bend as Net
```

BVLC type 129, function 10, length 24, so 20 octets follow the 4-octet header.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
BACNET 129 10 20
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/bacnet.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
BACNET 129 10 20
```
