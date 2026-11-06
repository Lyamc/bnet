# bnet-http

HTTP requests. `method` 1 is GET and 2 is POST. `major` and `minor` are the version numbers, so 1 and 1 are HTTP/1.1. `label` prints the method token and the version.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`HttpRequest`, `is_get`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_get`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-http`. Import the hyphen-free alias `bnet_http`:

```
import ../bnet_http/Protocol.bend as Net
```

Method 1 is GET. Version 1.1.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
HTTP GET/1.1
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/http.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
HTTP GET/1.1
```
