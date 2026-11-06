# bnet-ethernet

Ethernet II frames. `ethertype` is the 16-bit EtherType. 2048 (0x0800) means the payload is IPv4. The header in front of the payload is 14 octets, so `label` reports that EtherType and the header plus `payload_len`.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`EtherFrame`, `is_ipv4`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_ipv4`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-ethernet`. Import the hyphen-free alias `bnet_ethernet`:

```
import ../bnet_ethernet/Protocol.bend as Net
```

EtherType 2048 is IPv4. 14 + 64 = 78 octets of header plus payload.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
ETHERNET 2048 78
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/ethernet.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
ETHERNET 2048 78
```
