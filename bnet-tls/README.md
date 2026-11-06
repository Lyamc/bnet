# bnet-tls

TLS records. `content_type` 22 is a handshake and 23 is application data. `major` 3 and `minor` 3 are legacy version TLS 1.2. The on-wire record is `length + 5` because the header is 5 octets. `label` prints the content type, the version, and that size.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`TlsRecord`, `is_handshake`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_handshake`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-tls`. Import the hyphen-free alias `bnet_tls`:

```
import ../bnet_tls/Protocol.bend as Net
```

Content type 22 (handshake), version 3.3, length 40, so the record is 45 octets.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
TLS 22 3.3 45
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/tls.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
TLS 22 3.3 45
```
