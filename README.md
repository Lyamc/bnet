# bnet

Sixteen Bend packages for network protocols. Each package is self-contained: copy that directory alone and its test apps still run with `bend`. There is no shared library for them to import.

The packages:

- `bnet-ethernet`
- `bnet-ipv4`
- `bnet-ipv6`
- `bnet-modbus-rtu`
- `bnet-modbus-tcp`
- `bnet-bacnet`
- `bnet-arcnet`
- `bnet-http`
- `bnet-quic`
- `bnet-arp`
- `bnet-udp`
- `bnet-tcp`
- `bnet-dns`
- `bnet-tls`
- `bnet-websocket`
- `bnet-mqtt`

## Shared layout

Every package has the same relative paths:

- `README.md` — protocol, import line, and the `bend` command plus expected stdout for each test app
- `Protocol.bend` — the one public module
- `apps/show.bend` — calls `label` and prints it
- `apps/check.bend` — calls that package's predicate and prints it

In-package apps import the public module with a relative path:

```
import ./../Protocol.bend as Net
```

## Hyphen-free imports

The directories are named `bnet-<slug>`. Bend 2.0.5 treats `-` as syntax, so a hyphen inside an `import` path is not the form these packages publish. Each package has a sibling alias `bnet_<slug>` (hyphens in the slug become underscores) that points at the same tree. From a program in `imports/`, the import line is:

```
import ../bnet_<slug>/Protocol.bend as Net
```

The sixteen lines are:

```
import ../bnet_ethernet/Protocol.bend as Net
import ../bnet_ipv4/Protocol.bend as Net
import ../bnet_ipv6/Protocol.bend as Net
import ../bnet_modbus_rtu/Protocol.bend as Net
import ../bnet_modbus_tcp/Protocol.bend as Net
import ../bnet_bacnet/Protocol.bend as Net
import ../bnet_arcnet/Protocol.bend as Net
import ../bnet_http/Protocol.bend as Net
import ../bnet_quic/Protocol.bend as Net
import ../bnet_arp/Protocol.bend as Net
import ../bnet_udp/Protocol.bend as Net
import ../bnet_tcp/Protocol.bend as Net
import ../bnet_dns/Protocol.bend as Net
import ../bnet_tls/Protocol.bend as Net
import ../bnet_websocket/Protocol.bend as Net
import ../bnet_mqtt/Protocol.bend as Net
```

`imports/<slug>.bend` is the shipped program that uses that line and calls `label`. Its header states the `bend` command and the expected stdout.

## Running

From a package directory:

```
bend apps/show.bend
bend apps/check.bend
```

From this workspace:

```
bend bnet-ethernet/apps/show.bend
bend imports/ethernet.bend
```

Use the installed Bend 2.0.5 compiler. These apps are checked and run with `bend <file>`. They do not need a native build.
