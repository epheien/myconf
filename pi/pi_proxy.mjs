// 用于把 pi 的 api 流 dump 出来
import http from "node:http";
import net from "node:net";

const PORT = Number(process.env.PORT || 9090);

function log(...args) {
  const ts = new Date().toISOString().slice(11, 23);
  console.log(`[${ts}]`, ...args);
}

// 打印一段字节：
// - TLS 记录头(0x16 0x03 xx xx xx xx) -> 只报长度，不解密
// - 否则按 UTF-8 打印，控制字符转义
let bytes = 0;
function printChunk(dir, chunk) {
  bytes += chunk.length;
  const first = chunk[0];
  const looksTls = first === 0x16 && chunk[1] === 0x03;
  if (looksTls) {
    log(`  ${dir} TLS record, ${chunk.length} bytes (encrypted; use cert MITM to read)`);
    return;
  }
  let s = chunk.toString("utf8");
  s = s.replace(/[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]/g, (c) => `\\x${c.charCodeAt(0).toString(16).padStart(2, "0")}`);
  // 每行加缩进，避免和多条请求混在一起
  const lines = s.split("\n");
  for (const line of lines) log(`  ${dir} | ${line}`);
}

const server = http.createServer((req, res) => {
  const raw = req.url || "";
  const target = new URL(raw.startsWith("http") ? raw : `http://${req.headers.host}${raw}`);
  log(`HTTP (absolute-form? unexpected: pi uses CONNECT) ${req.method} ${target.href}`);
  res.writeHead(200, { "content-type": "text/plain" });
  res.end("this proxy only handles CONNECT; found plain http instead\n");
});

server.on("connect", (req, clientSocket, head) => {
  const [host, portStr] = (req.url || "").split(":");
  const port = Number(portStr) || 443;
  log(`CONNECT -> ${host}:${port}   (tunnel opened, printing payload)`);

  const upstream = net.connect(port, host, () => {
    clientSocket.write("HTTP/1.1 200 Connection Established\r\n\r\n");
    if (head && head.length) {
      log(`  C->S [${head.length} bytes before CONNECT ack]`);
      printChunk("C->S", head);
      upstream.write(head);
    }
  });

  clientSocket.on("data", (chunk) => {
    printChunk("C->S", chunk);
    upstream.write(chunk);
  });
  clientSocket.on("end", () => upstream.end());
  clientSocket.on("error", (e) => { log("client error: " + e.message); upstream.destroy(); });

  upstream.on("data", (chunk) => {
    printChunk("S->C", chunk);
    clientSocket.write(chunk);
  });
  upstream.on("end", () => clientSocket.end());
  upstream.on("error", (e) => { log(`upstream(${host}:${port}) error: ${e.message}`); clientSocket.destroy(); });
});

server.listen(PORT, () => {
  log(`Tunnel-printing proxy listening on 127.0.0.1:${PORT}`);
  log(`HTTP_PROXY=http://127.0.0.1:${PORT} HTTPS_PROXY=http://127.0.0.1:${PORT}`);
  log("Send a prompt in pi; tunnel payload (vllm=plaintext http) will print below.");
});
