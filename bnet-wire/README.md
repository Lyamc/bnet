# bnet-wire

A small capture tool in the same shape as the protocol packages. It prints one line per packet: index, captured length, original length, link type, and EtherType. Link type 1 is `EN10MB`. Any other link type is `DLT` plus the number, and its EtherType column is 0.

Opening a capture file and capturing live both go through an existing packet-capture library, not a Bend pcap parser. On Linux that library is libpcap (`libpcap.so.1`). On macOS it is `libpcap.dylib`. On Windows it is Npcap's `wpcap.dll`, which exports the same calls. If none of those is on the default search path, set `BNET_LIBPCAP` to the library file. On NixOS the loader also checks `/nix/store` for a `libpcap-*-lib` output.

Live capture calls `pcap_open_live`. If that open fails, it runs `dumpcap -i DEVICE -c N -a duration:2 -w FILE` and then reads the file `dumpcap` wrote. A missing permission prints that error and exits 0. It does not raise privileges itself.

`summary`, `is_ethernet`, and `result_text` are pure. `load_file`, `list_devs`, and `capture` are effects. Run them with `bend`. `bend -o` does not link libpcap. File reads stop at 256 packets. Live reads stop at 32 packets, or after two 500 ms timeouts.

This package depends on Bend `Base` plus the capture library above. The protocol packages do not import it. Its test apps import `./../Protocol.bend`. It is not one of the sixteen protocol packages, and it has no client, server, or session app.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`Packet`, `is_ethernet`, `summary`, `result_text`, `load_file`, `list_devs`, `capture`)
- `pcap.js`, `pcap.c` — the libpcap effect (`pcap.c` is a note; the JavaScript backend performs the calls)
- `fixtures/one.pcap` — one 60-octet Ethernet frame, EtherType 2048
- `apps/show.bend` — prints `summary` of that frame
- `apps/check.bend` — prints `is_ethernet`
- `apps/read.bend` — loads the fixture through libpcap
- `apps/devs.bend` — lists capture devices
- `apps/live.bend` — captures one packet from device `any`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-wire`. Import the hyphen-free alias `bnet_wire`:

```
import ../bnet_wire/Protocol.bend as Net
```

Every importer of this file uses the alias `Net`.

## Test apps

Run these from this directory. `show`, `check`, and `read` exit 0 and print the stdout below, including the final newline. `show` and `check` do not load libpcap.

### `bend apps/show.bend`

```
1 60 60 EN10MB 2048
```

### `bend apps/check.bend`

```
True
```

### `bend apps/read.bend`

```
1 60 60 EN10MB 2048
```

From the workspace root the same read is `bend bnet-wire/apps/read.bend`. The loader checks `fixtures/one.pcap` and then `bnet-wire/fixtures/one.pcap`.

### `bend apps/devs.bend`

Prints one device name per line, `none` when libpcap lists nothing, or the libpcap error. The names depend on this machine.

### `bend apps/live.bend`

Prints one summary line, `CAPTURE 0` when the open succeeds and no packet arrives, or a libpcap or dumpcap error. Output depends on this machine and on capture permission.

## Outside import

`imports/wire.bend` in the workspace root uses the import line above, calls `summary`, and prints:

```
1 60 60 EN10MB 2048
```
