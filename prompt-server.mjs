#!/usr/bin/env node
/**
 * MCP Prompt Loader (spec-friendly)
 * - Echoes client's protocolVersion in initialize
 * - Returns non-empty capabilities { prompts:{}, tools:{} }
 * - Implements prompts/list and prompts/get with content blocks
 * - Optional PROMPT_FILE (defaults to /prompt.txt)
 * - SIGHUP reload support
 */

import fs from "fs";
import readline from "readline";
import process from "process";

const PROMPT_PATH = process.env.PROMPT_FILE || "/prompt.txt";

function loadPromptOrExit() {
  try {
    const txt = fs.readFileSync(PROMPT_PATH, "utf8");
    console.error(
      `[INFO] Loaded prompt: ${PROMPT_PATH} (${txt.length} bytes, ${txt.split("\n").length} lines)`,
    );
    return txt;
  } catch (e) {
    console.error(`[ERROR] Failed to load ${PROMPT_PATH}: ${e.message}`);
    process.exit(1);
  }
}

let promptText = loadPromptOrExit();

const rl = readline.createInterface({ input: process.stdin });
const send = (obj) => process.stdout.write(JSON.stringify(obj) + "\n");

rl.on("line", (line) => {
  if (!line.trim()) return;
  let msg;
  try {
    msg = JSON.parse(line);
  } catch {
    console.error("[WARN] Ignoring non-JSON line");
    return;
  }

  const { id, method, params } = msg;

  // --- initialize: echo client's protocolVersion & return non-empty capabilities
  if (method === "initialize") {
    const clientProto = params?.protocolVersion || "2024-11-05";
    return send({
      jsonrpc: "2.0",
      id,
      result: {
        protocolVersion: clientProto,
        serverInfo: { name: "mcp-prompt-loader", version: "1.0.3" },
        capabilities: {
          prompts: { listChanged: false },
          tools: { listChanged: false },
        },
      },
    });
  }

  // --- prompts/list
  if (method === "prompts/list") {
    return send({
      jsonrpc: "2.0",
      id,
      result: {
        prompts: [
          {
            name: "default",
            description: `Prompt loaded from ${PROMPT_PATH}`,
            arguments: [],
          },
        ],
      },
    });
  }

  // --- prompts/get
  if (method === "prompts/get") {
    const name = params?.name ?? "default";
    if (name !== "default") {
      return send({
        jsonrpc: "2.0",
        id,
        error: { code: -32602, message: `Unknown prompt: ${name}` },
      });
    }
    return send({
      jsonrpc: "2.0",
      id,
      result: {
        description: `Prompt from ${PROMPT_PATH}`,
        messages: [
          {
            role: "system",
            content: [{ type: "text", text: promptText }],
          },
        ],
      },
    });
  }

  // --- (optional) tools/list (simple helper)
  if (method === "tools/list") {
    return send({
      jsonrpc: "2.0",
      id,
      result: {
        tools: [
          {
            name: "get_system_prompt",
            description: "Return the loaded system prompt text",
            inputSchema: {
              type: "object",
              properties: {},
              additionalProperties: false,
            },
          },
        ],
      },
    });
  }

  // --- (optional) tools/call
  if (method === "tools/call" && params?.name === "get_system_prompt") {
    return send({
      jsonrpc: "2.0",
      id,
      result: { content: [{ type: "text", text: promptText }] },
    });
  }

  // Unknown method: reply with JSON-RPC error if an id was provided
  if (id !== undefined) {
    send({
      jsonrpc: "2.0",
      id,
      error: { code: -32601, message: `Method not found: ${method}` },
    });
  }
});

// SIGHUP reload support
process.on("SIGHUP", () => {
  console.error("[INFO] SIGHUP received — reloading prompt...");
  promptText = loadPromptOrExit();
});
