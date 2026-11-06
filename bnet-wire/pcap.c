/* bnet-wire capture runs on the JavaScript backend.
   bend loads pcap.js, which calls libpcap, Npcap wpcap.dll, or libpcap.dylib.
   A native bend -o link line does not include libpcap, so this file
   intentionally has no capture calls. */
