# bnet-tcp

TCP segments. `flags` bit 2 (0x02) is SYN. `data_offset` counts 32-bit words, so the header is `data_offset * 4` octets. `label` prints the source port, the destination port, the flags, and that header size. The fixture is port 54321 to port 443.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`TcpSegment`, `is_syn`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_syn`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-tcp`. Import the hyphen-free alias `bnet_tcp`:

```
import ../bnet_tcp/Protocol.bend as Net
```

Port pair 54321 to 443. Flags 2 is SYN. Data offset 5 is a 20-octet header.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
TCP 54321 443 2 20
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/tcp.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
TCP 54321 443 2 20
```
