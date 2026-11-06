# bnet-mqtt

MQTT control packets. `packet_type` 1 is CONNECT. `flags` sits in the low nibble of the first byte. `remaining_length` counts the bytes after a one-byte remaining-length field, so the packet is `remaining_length + 2` octets. `label` prints the type, the flags, and that size.

This package depends only on Bend `Base`. Its test apps import `./../Protocol.bend` and nothing from another `bnet-*` package, so the directory can be copied on its own.

## Layout

- `README.md` — this file
- `Protocol.bend` — the public module (`MqttPacket`, `is_connect`, `label`)
- `apps/show.bend` — prints `label`
- `apps/check.bend` — prints `is_connect`

## Import

Bend 2.0.5 rejects `-` in an import path. The directory is `bnet-mqtt`. Import the hyphen-free alias `bnet_mqtt`:

```
import ../bnet_mqtt/Protocol.bend as Net
```

Packet type 1 (CONNECT), flags 0, remaining length 10, so the packet is 12 octets.

## Test apps

Run these from this directory. Each command exits 0 and prints the stdout below, including the final newline.

### `bend apps/show.bend`

```
MQTT 1 0 12
```

### `bend apps/check.bend`

```
True
```

## Outside import

`imports/mqtt.bend` in the workspace root uses the import line above, calls `label`, and prints:

```
MQTT 1 0 12
```
