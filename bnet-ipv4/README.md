# bnet-ipv4

IPv4 headers. `version` is 4. `ihl` counts 32-bit words, so the header is `ihl * 4` octets. `protocol` 6 is TCP. `label` prints version, protocol, and that header size.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`Ipv4Header`, `is_version_4`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_version_4`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-ipv4`. Import the hyphen-free alias `bnet_ipv4`:

```
import ../bnet_ipv4/Protocol.bend as Net
```

Version 4, protocol 6 (TCP), IHL 5 so the header is 20 octets.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
IPV4 4 6 20
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/ipv4.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
IPV4 4 6 20
```
