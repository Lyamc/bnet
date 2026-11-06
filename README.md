# bnet

Bend networking. The repository is [github.com/Lyamc/bnet](https://github.com/Lyamc/bnet).

Sixteen protocol packages live in this tree. Each one is a Bend module with a typed header, one predicate, and `label`. `apps/show.bend`, `apps/check.bend`, `apps/header.bend`, and `apps/session.bend` pass under Bend 2.0.5. A complete package parses and builds its on-wire header, and its session connects, exchanges two headers, and returns the expected errors. All 16 do.

Checked 2026-11-06.

| Stage | Count |
| --- | ---: |
| Complete | 16 |
| In progress, tested and working | 0 |
| In progress, not tested or not working | 0 |
| Not implemented yet | 0 |
| Total | 16 |

## Results

The result names match a pass / conditional pass / fail / skip chart.

| Result | Meaning | Count | Share | |
| --- | --- | ---: | ---: | --- |
| pass | Complete. Parses and builds the on-wire header, and `session` prints the expected lines. | 16 | 100% | `################` |
| conditional pass | In progress. `show` and `check` exit 0 and print the expected line. | 0 | 0% | |
| fail | In progress. The package is present and a test is missing or does not pass. | 0 | 0% | |
| skip | Not implemented yet. No package. | 0 | 0% | |
| | | 16 | | |

| Protocol | Package | Result |
| --- | --- | --- |
| Ethernet II | `bnet-ethernet` | pass |
| IPv4 | `bnet-ipv4` | pass |
| IPv6 | `bnet-ipv6` | pass |
| Modbus RTU | `bnet-modbus-rtu` | pass |
| Modbus TCP | `bnet-modbus-tcp` | pass |
| BACnet/IP | `bnet-bacnet` | pass |
| ARCnet | `bnet-arcnet` | pass |
| HTTP | `bnet-http` | pass |
| QUIC | `bnet-quic` | pass |
| ARP | `bnet-arp` | pass |
| UDP | `bnet-udp` | pass |
| TCP | `bnet-tcp` | pass |
| DNS | `bnet-dns` | pass |
| TLS | `bnet-tls` | pass |
| WebSocket | `bnet-websocket` | pass |
| MQTT | `bnet-mqtt` | pass |

## Layout

The packages are directories in this repository. Each protocol later moves to its own repository, and this tree pulls those repositories in as git submodules. Until that split, clone this repository and the packages are already here.

`bnet-wire` is the capture tool beside the sixteen. It loads a pcap through libpcap (Npcap `wpcap.dll` on Windows) and prints one summary line. Its `show`, `check`, and fixture `read` pass. It is not one of the sixteen rows in the chart. It stays in this repository with the protocol packages.

A package directory holds `README.md`, `Protocol.bend`, and `apps/`. `show`, `check`, and `header` exercise the codec. `apps/Exchange.bend` is the shared client and server. `server` listens on `127.0.0.1` for one header, and `client` sends one header to it. Start the server first. Ports run from 19100 for Ethernet through 19115 for MQTT. `session` starts both in one process: it connects, exchanges two headers, and then checks a wrong reply, a closed peer, a silent peer, and a refused port. `BNET_MODE` on the server selects `bad`, `reset`, or `silent`. From that directory:

```
bend apps/show.bend
bend apps/check.bend
bend apps/header.bend
bend apps/server.bend
bend apps/client.bend
bend apps/session.bend
```

Bend 2.0.5 treats `-` as syntax in an import path. Each directory `bnet-<name>` has a sibling symlink `bnet_<name>` for imports from outside the package:

```
import ../bnet_ethernet/Protocol.bend as Net
```

Inside a package, `show`, `check`, and `header` import `./../Protocol.bend`. `client`, `server`, and `session` import `./Exchange.bend`. `imports/<name>.bend` is the program at the repository root that uses the symlink.
