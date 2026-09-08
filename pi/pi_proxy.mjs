// 用于把 pi 的 api 流 dump 出来 (sglang=plaintext http)
import http from "node:http";
import net from "node:net";

const PORT = Number(process.env.PORT || 9090);
// 打印请求体时只打印前 N 字节,避免大 payload(如图像 base64)刷屏
const PRINT_BODY_MAX = 64 * 1024;

function log(...args) {
  const ts = new Date().toISOString().slice(11, 23);
  console.log(`[${ts}]`, ...args);
}

// 打印一段字节：
// - TLS 记录头(0x16 0x03 xx xx xx xx) -> 只报长度,不解密
// - 否则按 UTF-8 打印,控制字符转义
let bytes = 0;
// 每个连接独立的打印器:某方向一旦出现过 TLS 记录头(0x16 0x03 ...),
// 后续分片都视为加密只报长度,避免中途分片被当 UTF-8 打印成乱码。
// 状态按连接隔离,防止 https 隧道污染后续明文连接的打印。
function makePrinter(dir) {
  let tlsSeen = false;
  return (chunk) => {
    bytes += chunk.length;
    const first = chunk[0];
    const looksTls = (first === 0x16 && chunk[1] === 0x03) || tlsSeen;
    if (looksTls) {
      if (first === 0x16 && chunk[1] === 0x03) tlsSeen = true;
      log(`  ${dir} TLS record, ${chunk.length} bytes (encrypted; use cert MITM to read)`);
      return;
    }
    let s = chunk.toString("utf8");
    if (chunk.length > PRINT_BODY_MAX) {
      s = s.slice(0, PRINT_BODY_MAX) + `\n... [truncated, total ${chunk.length} bytes]`;
    }
    s = s.replace(/[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]/g, (c) => `\\x${c.charCodeAt(0).toString(16).padStart(2, "0")}`);
    // 每行加缩进,避免和多条请求混在一起
    for (const line of s.split("\n")) log(`  ${dir} | ${line}`);
  };
}

function stripHopByHop(headers) {
  const h = { ...headers };
  // RFC 2616: Connection 头里点名的字段同样属于逐跳字段
  const connTokens = (h.connection || "").split(",").map((t) => t.trim()).filter(Boolean);
  for (const k of [...connTokens, "connection", "keep-alive", "proxy-connection", "proxy-authenticate", "proxy-authorization", "te", "trailer", "transfer-encoding", "upgrade", "expect"]) delete h[k];
  return h;
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on("data", (c) => chunks.push(c));
    req.on("end", () => resolve(Buffer.concat(chunks)));
    req.on("error", reject);
  });
}

// ---- 普通 HTTP 请求 (absolute-form)。pi 的 API base 是明文 http:// 时走这里, ----
// ---- 不会走 CONNECT (CONNECT 只用于 https 目标)。 ----
const server = http.createServer(async (req, res) => {
  const printC2S = makePrinter("C->S");
  const printS2C = makePrinter("S->C");

  let target;
  try {
    target = new URL(req.url.startsWith("http") ? req.url : `http://${req.headers.host}${req.url}`);
  } catch {
    log(`  bad request url: ${req.url}`);
    res.writeHead(400, { "content-type": "text/plain" }).end("bad request url\n");
    return;
  }
  log(`HTTP ${req.method} ${target.href}`);

  // absolute-form 里出现 https:// 说明客户端没走 CONNECT,这里不支持直连 TLS,明确报错而非崩溃
  if (target.protocol !== "http:") {
    log(`  unsupported protocol ${target.protocol} (https 应走 CONNECT)`);
    res.writeHead(501, { "content-type": "text/plain" }).end("only http:// supported via absolute-form; https 应走 CONNECT\n");
    return;
  }

  let body;
  try {
    body = await readBody(req);
  } catch (e) {
    log(`  error reading request body: ${e.message}`);
    res.writeHead(400, { "content-type": "text/plain" }).end("bad request body\n");
    return;
  }
  if (body.length) printC2S(body);

  const headers = stripHopByHop(req.headers);
  headers.host = target.host;
  if (req.headers["content-length"] !== undefined || body.length > 0) headers["content-length"] = String(body.length);
  headers.connection = "close"; // 每个请求用独立上游连接,简单可靠

  const up = http.request(target, { method: req.method, headers, agent: false }, (upRes) => {
    const respHeaders = stripHopByHop(upRes.headers);
    const cl = respHeaders["content-length"];
    log(`  S->C ${upRes.statusCode} ${upRes.statusMessage || ""} content-type=${respHeaders["content-type"] || "-"}${cl ? ` content-length=${cl}` : " (chunked/streaming)"}`);
    upRes.on("data", (chunk) => printS2C(chunk));
    upRes.on("error", (e) => {
      // 上游响应中途断开:截断响应即可,进程不能崩
      log(`  upstream response error: ${e.message}`);
      if (!res.writableEnded) res.end();
    });
    res.writeHead(upRes.statusCode, respHeaders);
    upRes.pipe(res);
  });
  up.on("error", (e) => {
    log(`  upstream(${target.host}) error: ${e.message}`);
    if (!res.writableEnded) {
      if (!res.headersSent) {
        res.writeHead(502, { "content-type": "text/plain" });
        res.end(`upstream error: ${e.message}\n`);
      } else {
        res.end(); // 响应已开始,截断
      }
    }
  });
  // 客户端中途断开(pi 取消生成)→ 立即切断上游,避免远端继续烧 token
  res.on("close", () => { if (!res.writableEnded) up.destroy(); });
  res.on("error", (e) => { log(`  client response error: ${e.message}`); up.destroy(); });
  up.end(body);
});

server.on("connect", (req, clientSocket, head) => {
  const [host, portStr] = (req.url || "").split(":");
  const port = Number(portStr) || 443;
  const printC2S = makePrinter("C->S");
  const printS2C = makePrinter("S->C");
  log(`CONNECT -> ${host}:${port}   (tunnel opened, printing payload)`);

  const upstream = net.connect(port, host, () => {
    clientSocket.write("HTTP/1.1 200 Connection Established\r\n\r\n");
    if (head && head.length) {
      log(`  C->S [${head.length} bytes before CONNECT ack]`);
      printC2S(head);
      upstream.write(head);
    }
  });

  clientSocket.on("data", (chunk) => {
    printC2S(chunk);
    upstream.write(chunk);
  });
  clientSocket.on("end", () => upstream.end());
  clientSocket.on("error", (e) => { log("client error: " + e.message); upstream.destroy(); });

  upstream.on("data", (chunk) => {
    printS2C(chunk);
    clientSocket.write(chunk);
  });
  upstream.on("end", () => clientSocket.end());
  upstream.on("error", (e) => { log(`upstream(${host}:${port}) error: ${e.message}`); clientSocket.destroy(); });
});

server.listen(PORT, () => {
  log(`Tunnel-printing proxy listening on 127.0.0.1:${PORT}`);
  log(`HTTP_PROXY=http://127.0.0.1:${PORT} HTTPS_PROXY=http://127.0.0.1:${PORT}`);
  log("Send a prompt in pi; tunnel payload (sglang=plaintext http) will print below.");
});
