# bnet-arp

ARP messages. `oper` 1 is a request and 2 is a reply. `ptype` 2048 (0x0800) is IPv4. `hlen` 6 and `plen` 4 are Ethernet and IPv4 address lengths. `label` prints the opcode, the protocol type, and those two lengths.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`ArpMessage`, `is_request`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_request`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-arp`. Import the hyphen-free alias `bnet_arp`:

```
import ../bnet_arp/Protocol.bend as Net
```

Opcode 1 (request), protocol type 2048, hardware length 6, protocol length 4.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
ARP 1 2048 6 4
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/arp.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
ARP 1 2048 6 4
```
