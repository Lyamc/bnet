# bnet-udp

UDP datagrams. The header is 8 octets and `length` includes it, so the payload is `length - 8`. `label` prints the source port, the destination port, and that payload size. The fixture is port 40534 to port 53.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`UdpDatagram`, `is_dns_port`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_dns_port`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-udp`. Import the hyphen-free alias `bnet_udp`:

```
import ../bnet_udp/Protocol.bend as Net
```

Port pair 40534 to 53. Length 28 includes the 8-octet header, so the payload is 20.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
UDP 40534 53 20
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/udp.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
UDP 40534 53 20
```
