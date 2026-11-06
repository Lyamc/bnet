# bnet-quic

QUIC long-header fields. `version` 1 is QUIC version 1 (0x00000001). Connection-id octets are `dcid_len + scid_len`. `label` prints the version, that sum, and `token_len`.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`QuicLongHeader`, `is_version_1`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_version_1`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-quic`. Import the hyphen-free alias `bnet_quic`:

```
import ../bnet_quic/Protocol.bend as Net
```

Version 1. DCID 8 plus SCID 8 is 16 octets. Token length 0.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
QUIC 1 16 0
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/quic.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
QUIC 1 16 0
```
