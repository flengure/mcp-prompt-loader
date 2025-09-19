#!/usr/bin/env node
import fs from "fs";
import path from "path";
import process from "process";

/**
 * MCP Prompt Loader — Folder Mode (v2.0.0-dev)
 * - Hard-coded mount point: /prompts (no env var to drift)
 * - Supports MCP native prompts methods and tool calls:
 *     - prompts/list
 *     - prompts/get   (params: { name })
 *     - tools/list    -> list_prompts, get_prompt_by_name
 *     - tools/call    (list_prompts | get_prompt_by_name)
 */

const PROMPT_DIR = "/prompts";
const MAX_BYTES = 512 * 1024; // 512 KB/file cap
const NAME_RE = /^[a-zA-Z0-9._-]+$/; // safe names only

const log = (lvl, msg) => console.error(`[${lvl}] ${msg}`);
const send = (obj) => process.stdout.write(JSON.stringify(obj) + "\n");

// Ensure mount exists
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
      .map((e) => e.name.replace(/\.txt$/i, "")) // expose names WITHOUT .txt
      .filter((n) => NAME_RE.test(n))
      .sort((a, b) => a.localeCompare(b));
  } catch {
    return [];
  }
}

function readPrompt(name) {
  if (!NAME_RE.test(name)) throw new Error("invalid name");
  const fp = path.join(PROMPT_DIR, `${name}.txt`);
  const st = fs.statSync(fp);
  if (!st.isFile()) throw new Error("not a file");
  if (st.size > MAX_BYTES) throw new Error(`file too large (${st.size} bytes)`);
  let txt = fs.readFileSync(fp, "utf8");
  if (txt.charCodeAt(0) === 0xfeff) txt = txt.slice(1); // strip BOM
  return txt.replace(/\r\n/g, "\n");
}

// ---------------- MCP loop ----------------
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

    // initialize
    if (method === "initialize") {
      const clientProto = params?.protocolVersion || "2024-11-05";
      send({
        jsonrpc: "2.0",
        id,
        result: {
          protocolVersion: clientProto,
          serverInfo: { name: "mcp-prompt-loader", version: "2.0.0-dev" },
          // capabilities are optional; tools are discovered via tools/list
          capabilities: {
            prompts: { listChanged: false },
            tools: { listChanged: false },
          },
        },
      });
      continue;
    }

    // ----- native prompts API (for clients that use it) -----
    if (method === "prompts/list") {
      const names = listPromptNames();
      send({
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
      continue;
    }

    if (method === "prompts/get") {
      try {
        const name = params?.name;
        if (!name) throw new Error("missing name");
        const text = readPrompt(name);
        send({
          jsonrpc: "2.0",
          id,
          result: {
            description: `Prompt "${name}"`,
            messages: [{ role: "system", content: [{ type: "text", text }] }],
          },
        });
      } catch (e) {
        send({
          jsonrpc: "2.0",
          id,
          error: { code: -32602, message: e.message },
        });
      }
      continue;
    }

    // ----- tools -----
    if (method === "tools/list") {
      send({
        jsonrpc: "2.0",
        id,
        result: {
          tools: [
            {
              name: "list_prompts",
              description: "Return available prompt names (folder mode)",
              inputSchema: {
                type: "object",
                properties: {},
                additionalProperties: false,
              },
            },
            {
              name: "get_prompt_by_name",
              description: "Return prompt text by name (argument: { name })",
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
      continue;
    }

    if (method === "tools/call") {
      const tool = params?.name;

      if (tool === "list_prompts") {
        const names = listPromptNames();
        send({
          jsonrpc: "2.0",
          id,
          result: { content: [{ type: "text", text: JSON.stringify(names) }] },
        });
        continue;
      }

      if (tool === "get_prompt_by_name") {
        try {
          const name = params?.arguments?.name;
          const text = readPrompt(name);
          send({
            jsonrpc: "2.0",
            id,
            result: { content: [{ type: "text", text }] },
          });
        } catch (e) {
          send({
            jsonrpc: "2.0",
            id,
            error: { code: -32602, message: e.message },
          });
        }
        continue;
      }
    }

    // unknown
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
