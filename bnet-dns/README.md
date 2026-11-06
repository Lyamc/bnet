# bnet-dns

DNS messages. The QR bit is bit 15 of `flags` (mask 32768). QR 0 is a query. `qtype` 1 is an A record. `qdcount` is the number of questions. `label` prints the extracted QR bit, the QTYPE, and the question count.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`DnsMessage`, `is_query`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_query`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-dns`. Import the hyphen-free alias `bnet_dns`:

```
import ../bnet_dns/Protocol.bend as Net
```

Flags 0, so QR is 0 (query). QTYPE 1 is A. One question.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
DNS 0 1 1
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/dns.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
DNS 0 1 1
```
