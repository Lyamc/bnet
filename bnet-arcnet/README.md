# bnet-arcnet

ARCnet frames. `soh` is the start-of-header marker and is 1 (0x01) on a data frame. `did` 0 is the broadcast address. `count` is the short-frame data length. `label` prints the marker, the destination, and the count.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`ArcFrame`, `is_soh`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_soh`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-arcnet`. Import the hyphen-free alias `bnet_arcnet`:

```
import ../bnet_arcnet/Protocol.bend as Net
```

SOH marker 1, broadcast DID 0, count 16.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
ARCNET 1 0 16
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/arcnet.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
ARCNET 1 0 16
```
