import Base

# bnet-wire: one summary line for a captured frame.
# Link type 1 is Ethernet. The sample frame is index 1, 60 octets captured
# and on the wire, EtherType 2048 (IPv4).

type Packet is Data:
  Packet{index: U32, caplen: U32, wirelen: U32, link: U32, ethertype: U32}

def is_ethernet(pkt: Packet) -> Bool:
  match pkt:
    case Packet{index, caplen, wirelen, link, ethertype}:
      U32.is_eq(link, 1)

def link_token(is_en: Bool, link: U32) -> String:
  match is_en:
    case True{}:
      "EN10MB"
    case False{}:
      "DLT" ++ U32.show(link)

def summary(pkt: Packet) -> String:
  match pkt:
    case Packet{index, caplen, wirelen, +link, ethertype}:
      U32.show(index) ++ " " ++ U32.show(caplen) ++ " " ++ U32.show(wirelen) ++ " " ++ link_token(U32.is_eq(link, 1), link) ++ " " ++ U32.show(ethertype)

def result_text(got: Result<&1, &1, U32 & String, String>) -> String:
  match got:
    case Done{value}:
      value
    case Fail{(code, message)}:
      message

# File and live capture go through pcap.js (libpcap, or Npcap wpcap.dll).
# bend -o does not link libpcap; run these with bend.

def load_file(path: String, limit: U32) -> IO(Result<&1, &1, U32 & String, String>):
  import "./pcap.c"
  import "./pcap.js"

def list_devs() -> IO(Result<&1, &1, U32 & String, String>):
  import "./pcap.c"
  import "./pcap.js"

def capture(device: String, count: U32) -> IO(Result<&1, &1, U32 & String, String>):
  import "./pcap.c"
  import "./pcap.js"
