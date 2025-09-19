#!/usr/bin/env node

/**
 * MCP Prompt Loader Server
 *
 * Loads a system prompt from a mounted file and serves it via MCP (stdio).
 */

import fs from "fs";
import process from "process";

// Default prompt file inside container
const promptFile = process.env.PROMPT_FILE || "/prompt.txt";

function loadPrompt(file) {
  try {
    const text = fs.readFileSync(file, "utf-8");
    console.error(
      `[INFO] Loaded prompt: ${file} (${text.length} bytes, ${text.split("\n").length} lines)`,
    );
    return text;
  } catch (err) {
    console.error(`[ERROR] Could not load prompt file: ${file}`, err);
    process.exit(1);
  }
}

// Load prompt once at startup
let prompt = loadPrompt(promptFile);

// Helper to send JSON-RPC messages over stdout
function send(message) {
  process.stdout.write(JSON.stringify(message) + "\n");
}

process.stdin.setEncoding("utf-8");
process.stdin.on("data", (chunk) => {
  chunk
    .trim()
    .split("\n")
    .forEach((line) => {
      if (!line) return;
      try {
        const msg = JSON.parse(line);

        if (msg.method === "initialize") {
          send({
            jsonrpc: "2.0",
            id: msg.id,
            result: {
              serverInfo: { name: "mcp-prompt-loader", version: "1.0.0" },
              capabilities: {},
            },
          });
        } else if (msg.method === "getPrompt") {
          send({
            jsonrpc: "2.0",
            id: msg.id,
            result: { prompt },
          });
        } else if (msg.method === "reload") {
          prompt = loadPrompt(promptFile);
          send({
            jsonrpc: "2.0",
            id: msg.id,
            result: { reloaded: true },
          });
        } else {
          send({
            jsonrpc: "2.0",
            id: msg.id,
            error: { code: -32601, message: "Method not found" },
          });
        }
      } catch (err) {
        console.error("[ERROR] Failed to parse incoming JSON:", err);
      }
    });
});

// Allow container reload with SIGHUP
process.on("SIGHUP", () => {
  prompt = loadPrompt(promptFile);
});
