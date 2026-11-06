# bnet-ipv6

IPv6 headers. `version` is 6. The fixed header is 40 octets, so a datagram is 40 plus `payload_length`. `next_header` 17 is UDP. `label` prints version, next header, and that datagram size.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`Ipv6Header`, `is_version_6`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_version_6`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-ipv6`. Import the hyphen-free alias `bnet_ipv6`:

```
import ../bnet_ipv6/Protocol.bend as Net
```

Version 6, next header 17 (UDP), payload 32, so 40 + 32 = 72 octets.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
IPV6 6 17 72
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/ipv6.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
IPV6 6 17 72
```
