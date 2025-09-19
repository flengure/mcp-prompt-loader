#!/usr/bin/env node
import fs from "fs";
import path from "path";
import process from "process";

// Hard-coded mount point (no env var to drift)
const PROMPT_DIR = "/prompts";
const MAX_BYTES = 512 * 1024; // 512 KB/file cap
const NAME_RE = /^[a-zA-Z0-9._-]+$/; // safe names

const log = (lvl, msg) => console.error(`[${lvl}] ${msg}`);
const send = (obj) => process.stdout.write(JSON.stringify(obj) + "\n");

if (!fs.existsSync(PROMPT_DIR)) {
  log(
    "ERROR",
    `Missing prompt folder: ${PROMPT_DIR}. Did you mount -v /host/path:${PROMPT_DIR}:ro ?`,
  );
  process.exit(1);
}

function listPromptNames() {
  try {
    return fs
      .readdirSync(PROMPT_DIR, { withFileTypes: true })
      .filter((e) => e.isFile() && e.name.endsWith(".txt"))
      .map((e) => e.name.replace(/\.txt$/i, "")) // names WITHOUT .txt
      .filter((n) => NAME_RE.test(n))
      .sort((a, b) => a.localeCompare(b));
  } catch {
    return [];
  }
}

function readPrompt(name) {
  if (!NAME_RE.test(name)) throw new Error("invalid name");
  const p = path.join(PROMPT_DIR, `${name}.txt`);
  const st = fs.statSync(p);
  if (!st.isFile()) throw new Error("not a file");
  if (st.size > MAX_BYTES) throw new Error(`file too large (${st.size} bytes)`);
  let txt = fs.readFileSync(p, "utf8");
  if (txt.charCodeAt(0) === 0xfeff) txt = txt.slice(1); // strip BOM
  return txt.replace(/\r\n/g, "\n");
}

process.stdin.setEncoding("utf8");
let buf = "";

process.stdin.on("data", (chunk) => {
  buf += chunk;
  for (;;) {
    const nl = buf.indexOf("\n");
    if (nl < 0) break;
    const line = buf.slice(0, nl).trim();
    buf = buf.slice(nl + 1);
    if (!line) continue;

    let msg;
    try {
      msg = JSON.parse(line);
    } catch {
      log("WARN", "ignored non-JSON line");
      continue;
    }

    const { id, method, params } = msg;

    if (method === "initialize") {
      const clientProto = params?.protocolVersion || "2024-11-05";
      return send({
        jsonrpc: "2.0",
        id,
        result: {
          protocolVersion: clientProto,
          serverInfo: { name: "mcp-prompt-loader", version: "2.0.0-dev" },
          capabilities: {
            prompts: { listChanged: false },
            tools: { listChanged: false },
          },
        },
      });
    }

    if (method === "prompts/list") {
      const names = listPromptNames();
      return send({
        jsonrpc: "2.0",
        id,
        result: {
          prompts: names.map((n) => ({
            name: n,
            description: `Loaded from ${path.join(PROMPT_DIR, n + ".txt")}`,
            arguments: [],
          })),
        },
      });
    }

    if (method === "prompts/get") {
      try {
        const name = params?.name;
        if (!name) throw new Error("missing name");
        const text = readPrompt(name);
        return send({
          jsonrpc: "2.0",
          id,
          result: {
            description: `Prompt "${name}"`,
            messages: [{ role: "system", content: [{ type: "text", text }] }],
          },
        });
      } catch (e) {
        return send({
          jsonrpc: "2.0",
          id,
          error: { code: -32602, message: e.message },
        });
      }
    }

    if (method === "tools/list") {
      return send({
        jsonrpc: "2.0",
        id,
        result: {
          tools: [
            {
              name: "get_prompt_by_name",
              description: "Return prompt text by name",
              inputSchema: {
                type: "object",
                properties: { name: { type: "string" } },
                required: ["name"],
                additionalProperties: false,
              },
            },
          ],
        },
      });
    }

    if (method === "tools/call" && params?.name === "get_prompt_by_name") {
      try {
        const name = params?.arguments?.name;
        const text = readPrompt(name);
        return send({
          jsonrpc: "2.0",
          id,
          result: { content: [{ type: "text", text }] },
        });
      } catch (e) {
        return send({
          jsonrpc: "2.0",
          id,
          error: { code: -32602, message: e.message },
        });
      }
    }

    if (id !== undefined) {
      send({
        jsonrpc: "2.0",
        id,
        error: { code: -32601, message: `Method not found: ${method}` },
      });
    }
  }
});

process.on("SIGHUP", () => {
  // folder mode reads on demand; nothing to refresh
  log("INFO", "SIGHUP received.");
});

log("INFO", `Folder mode active. Serving from: ${PROMPT_DIR}`);
