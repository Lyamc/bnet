// Capture through libpcap (Linux/macOS) or Npcap wpcap.dll (Windows).
// A summary line matches Protocol.summary:
//   index caplen wirelen EN10MB|DLTn ethertype

const PCAP_ERRBUF = 256;
const FILE_CAP = 256;
const LIVE_CAP = 32;
const LIVE_MS = 500;
const LIVE_TIMEOUTS = 2;
const SNAPLEN = 65535;

const SYMBOLS = {
  pcap_open_offline: { args: ["cstring", "ptr"], returns: "ptr" },
  pcap_open_live: { args: ["cstring", "i32", "i32", "i32", "ptr"], returns: "ptr" },
  pcap_datalink: { args: ["ptr"], returns: "i32" },
  pcap_next_ex: { args: ["ptr", "ptr", "ptr"], returns: "i32" },
  pcap_close: { args: ["ptr"], returns: "void" },
  pcap_findalldevs: { args: ["ptr", "ptr"], returns: "i32" },
  pcap_freealldevs: { args: ["ptr"], returns: "void" },
  pcap_geterr: { args: ["ptr"], returns: "cstring" },
};

let cached;
let cachedWhy = "libpcap was not found. Set BNET_LIBPCAP to libpcap.so.1, libpcap.dylib, or wpcap.dll.";

function fail(msg) {
  return { $: "Fail", error: io_tup(1, String(msg)) };
}

function ok(text) {
  return io_done(String(text));
}

function isNull(p) {
  return p === null || p === undefined || p === 0 || p === 0n;
}

function clamp(n, max) {
  const x = Number(n);
  if (!Number.isFinite(x) || x <= 0) {
    return 0;
  }
  return Math.min(Math.floor(x), max);
}

function textBuf(buf) {
  const n = buf.indexOf(0);
  const end = n < 0 ? buf.length : n;
  return new TextDecoder().decode(buf.subarray(0, end)).trim();
}

function readCString(ffi, ptr) {
  const bytes = [];
  for (let i = 0; i < 256; i++) {
    const c = ffi.read.u8(ptr, i);
    if (c === 0) {
      break;
    }
    bytes.push(c);
  }
  return new TextDecoder().decode(Uint8Array.from(bytes));
}

function fileOk(fs, p) {
  try {
    return fs.statSync(p).isFile();
  } catch (e) {
    return false;
  }
}

function resolveCapture(p) {
  const fs = require("fs");
  if (fileOk(fs, p)) {
    return p;
  }
  const alt = "bnet-wire/" + p;
  if (fileOk(fs, alt)) {
    return alt;
  }
  return p;
}

function candidates() {
  const out = [];
  if (process.env.BNET_LIBPCAP) {
    out.push(process.env.BNET_LIBPCAP);
  }
  if (process.platform === "win32") {
    out.push(
      "wpcap.dll",
      "C:\\Windows\\System32\\Npcap\\wpcap.dll",
      "C:\\Windows\\SysWOW64\\Npcap\\wpcap.dll",
    );
  } else if (process.platform === "darwin") {
    out.push(
      "libpcap.dylib",
      "libpcap.A.dylib",
      "/usr/lib/libpcap.dylib",
      "/usr/lib/libpcap.A.dylib",
      "/opt/homebrew/lib/libpcap.dylib",
      "/usr/local/lib/libpcap.dylib",
    );
  } else {
    out.push(
      "libpcap.so.1",
      "libpcap.so",
      "/usr/lib/libpcap.so.1",
      "/usr/lib64/libpcap.so.1",
      "/usr/lib/x86_64-linux-gnu/libpcap.so.1",
      "/usr/lib/aarch64-linux-gnu/libpcap.so.1",
    );
    try {
      const names = require("fs").readdirSync("/nix/store");
      for (const name of names) {
        if (name.includes("libpcap") && name.endsWith("-lib")) {
          out.push("/nix/store/" + name + "/lib/libpcap.so.1");
        }
      }
    } catch (e) {
    }
  }
  return out;
}

function openLib() {
  if (cached !== undefined) {
    return cached;
  }
  const ffi = require("bun:ffi");
  const fs = require("fs");
  for (const path of candidates()) {
    if (path.includes("/") || path.includes("\\")) {
      try {
        if (!fs.existsSync(path)) {
          continue;
        }
      } catch (e) {
        continue;
      }
    }
    try {
      cached = { ffi: ffi, lib: ffi.dlopen(path, SYMBOLS), path: path };
      return cached;
    } catch (e) {
      cachedWhy = "libpcap at " + path + ": " + (e && e.message ? e.message : String(e));
    }
  }
  cached = null;
  return null;
}

function packetLine(ffi, index, dlt, hdr, data) {
  const capOff = process.platform === "win32" ? 8 : 16;
  const cap = ffi.read.u32(hdr, capOff);
  const len = ffi.read.u32(hdr, capOff + 4);
  let etype = 0;
  if (dlt === 1 && cap >= 14) {
    const hi = ffi.read.u8(data, 12);
    const lo = ffi.read.u8(data, 13);
    etype = ((hi << 8) | lo) >>> 0;
  }
  const link = dlt === 1 ? "EN10MB" : "DLT" + String(dlt);
  return index + " " + cap + " " + len + " " + link + " " + etype;
}

function handleErr(lib, handle) {
  try {
    const s = lib.symbols.pcap_geterr(handle);
    return s ? String(s) : "libpcap error";
  } catch (e) {
    return "libpcap error";
  }
}

function closeHandle(lib, handle) {
  try {
    lib.symbols.pcap_close(handle);
  } catch (e) {
  }
}

function collect(opened, handle, limit, live) {
  const ffi = opened.ffi;
  const lib = opened.lib;
  const dlt = lib.symbols.pcap_datalink(handle) | 0;
  const hdr = new BigUint64Array(1);
  const data = new BigUint64Array(1);
  const lines = [];
  let timeouts = 0;
  while (lines.length < limit) {
    hdr[0] = 0n;
    data[0] = 0n;
    const rc = lib.symbols.pcap_next_ex(handle, hdr, data) | 0;
    if (rc === 1) {
      if (isNull(hdr[0]) || isNull(data[0])) {
        return { error: "libpcap returned an empty packet" };
      }
      lines.push(packetLine(ffi, lines.length + 1, dlt, hdr[0], data[0]));
      timeouts = 0;
      continue;
    }
    if (rc === 0) {
      timeouts += 1;
      if (!live || timeouts >= LIVE_TIMEOUTS) {
        break;
      }
      continue;
    }
    if (rc === -2) {
      break;
    }
    return { error: handleErr(lib, handle) };
  }
  return { lines: lines };
}

function readPath(opened, path, limit) {
  const err = new Uint8Array(PCAP_ERRBUF);
  const handle = opened.lib.symbols.pcap_open_offline(path, err);
  if (isNull(handle)) {
    return { error: textBuf(err) || "could not open capture" };
  }
  try {
    return collect(opened, handle, limit, false);
  } finally {
    closeHandle(opened.lib, handle);
  }
}

function dumpcapFile(device, count) {
  const fs = require("fs");
  const os = require("os");
  const path = require("path");
  const cp = require("child_process");
  const file = path.join(os.tmpdir(), "bnet-wire-" + process.pid + "-" + Date.now() + ".pcap");
  let child;
  try {
    child = cp.spawnSync("dumpcap", [
      "-i", device,
      "-c", String(count),
      "-a", "duration:2",
      "-w", file,
    ], { timeout: 8000, encoding: "utf8" });
  } catch (e) {
    try {
      fs.unlinkSync(file);
    } catch (ignore) {
    }
    return { error: e && e.message ? e.message : String(e) };
  }
  if (child.error) {
    try {
      fs.unlinkSync(file);
    } catch (ignore) {
    }
    return { error: child.error.message };
  }
  let size = 0;
  try {
    size = fs.statSync(file).size;
  } catch (e) {
    size = 0;
  }
  if (size < 24) {
    try {
      fs.unlinkSync(file);
    } catch (ignore) {
    }
    const raw = (child.stderr || child.stdout || "").trim();
    const lines = raw.split(/\r?\n/).map((s) => s.trim()).filter(Boolean);
    const named = lines.filter((s) => s.startsWith("dumpcap:"));
    const picked = named.length > 0 ? named[named.length - 1] : lines[lines.length - 1];
    return { error: picked || ("dumpcap exited " + child.status) };
  }
  return { file: file };
}

function guard(run) {
  try {
    return run();
  } catch (e) {
    return fail(e && e.message ? e.message : String(e));
  }
}

function load_file(path, limit) {
  return guard(() => {
    if (typeof path !== "string" || path.length === 0 || path.includes("\0") || path === "-") {
      return fail("capture path must be a file");
    }
    const opened = openLib();
    if (opened === null) {
      return fail(cachedWhy);
    }
    const got = readPath(opened, resolveCapture(path), clamp(limit, FILE_CAP));
    if (got.error) {
      return fail(got.error);
    }
    return ok(got.lines.join("\n"));
  });
}

function list_devs() {
  return guard(() => {
    const opened = openLib();
    if (opened === null) {
      return fail(cachedWhy);
    }
    const ffi = opened.ffi;
    const slot = new BigUint64Array(1);
    const err = new Uint8Array(PCAP_ERRBUF);
    const rc = opened.lib.symbols.pcap_findalldevs(slot, err) | 0;
    if (rc !== 0) {
      return fail(textBuf(err) || "pcap_findalldevs failed");
    }
    if (isNull(slot[0])) {
      return ok("none");
    }
    const ptrSize = process.arch === "ia32" ? 4 : 8;
    const names = [];
    let p = slot[0];
    try {
      while (!isNull(p) && names.length < 256) {
        const namePtr = ffi.read.ptr(p, ptrSize);
        if (!isNull(namePtr)) {
          names.push(readCString(ffi, namePtr));
        }
        const next = ffi.read.ptr(p, 0);
        if (next === p) {
          break;
        }
        p = next;
      }
    } finally {
      opened.lib.symbols.pcap_freealldevs(slot[0]);
    }
    return ok(names.length === 0 ? "none" : names.join("\n"));
  });
}

function capture(device, count) {
  return guard(() => {
    if (typeof device !== "string" || device.length === 0 || device.includes("\0") || device.startsWith("-")) {
      return fail("device name must not start with '-'");
    }
    const n = clamp(count, LIVE_CAP);
    if (n === 0) {
      return ok("CAPTURE 0");
    }
    const opened = openLib();
    if (opened === null) {
      return fail(cachedWhy);
    }
    const err = new Uint8Array(PCAP_ERRBUF);
    const handle = opened.lib.symbols.pcap_open_live(device, SNAPLEN, 0, LIVE_MS, err);
    if (!isNull(handle)) {
      try {
        const got = collect(opened, handle, n, true);
        if (got.error) {
          return fail(got.error);
        }
        return ok(got.lines.length === 0 ? "CAPTURE 0" : got.lines.join("\n"));
      } finally {
        closeHandle(opened.lib, handle);
      }
    }
    const why = textBuf(err) || "pcap_open_live failed";
    const dumped = dumpcapFile(device, n);
    if (dumped.error) {
      const extra = dumped.error.startsWith("dumpcap:") ? dumped.error : "dumpcap: " + dumped.error;
      return fail("libpcap: " + why + "; " + extra);
    }
    try {
      const got = readPath(opened, dumped.file, n);
      if (got.error) {
        return fail(got.error);
      }
      return ok(got.lines.length === 0 ? "CAPTURE 0" : got.lines.join("\n"));
    } finally {
      try {
        require("fs").unlinkSync(dumped.file);
      } catch (e) {
      }
    }
  });
}
