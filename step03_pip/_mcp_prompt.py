"""Minimal MCP client for the local prompt-optimizer service.

Why this exists: PowerShell's Invoke-WebRequest gets a 502 from the system
proxy for localhost, so the call must go through python urllib with an empty
ProxyHandler. The transport is streamable HTTP with SSE frames.

Usage:
    python step03_pip/_mcp_prompt.py --tool optimize-user-prompt --prompt "..."
    python step03_pip/_mcp_prompt.py --tool optimize-user-prompt --file draft.md \
        --out step03_pip/PROMPT_XXX_V1.md
"""
import argparse
import json
import urllib.request

BASE = "http://127.0.0.1:8081/mcp"
OPENER = urllib.request.build_opener(urllib.request.ProxyHandler({}))
HEADERS = {
    "Content-Type": "application/json",
    "Accept": "application/json, text/event-stream",
}


def _post(payload, sid=None):
    headers = dict(HEADERS)
    if sid:
        headers["Mcp-Session-Id"] = sid
    req = urllib.request.Request(
        BASE, data=json.dumps(payload).encode("utf-8"), headers=headers, method="POST"
    )
    with OPENER.open(req, timeout=180) as r:
        raw = r.read().decode("utf-8", "replace")
        return r.headers.get("Mcp-Session-Id") or sid, raw


def _parse_sse(raw):
    """Return the last JSON object carried by an SSE stream (or a bare JSON body)."""
    out = None
    for line in raw.splitlines():
        if line.startswith("data:"):
            body = line[5:].strip()
            if body:
                try:
                    out = json.loads(body)
                except json.JSONDecodeError:
                    pass
    if out is None:
        try:
            out = json.loads(raw)
        except json.JSONDecodeError:
            out = None
    return out


def call(tool, arguments):
    sid, raw = _post(
        {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
                "protocolVersion": "2024-11-05",
                "capabilities": {},
                "clientInfo": {"name": "dsh", "version": "1"},
            },
        }
    )
    _post({"jsonrpc": "2.0", "method": "notifications/initialized"}, sid)
    _, raw = _post(
        {
            "jsonrpc": "2.0",
            "id": 2,
            "method": "tools/call",
            "params": {"name": tool, "arguments": arguments},
        },
        sid,
    )
    msg = _parse_sse(raw)
    if not msg:
        raise SystemExit("no JSON in response:\n" + raw[:2000])
    if "error" in msg:
        raise SystemExit("MCP error: " + json.dumps(msg["error"], ensure_ascii=False))
    res = msg.get("result", {})
    parts = [c.get("text", "") for c in res.get("content", []) if c.get("type") == "text"]
    return "\n".join(parts)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tool", default="optimize-user-prompt")
    ap.add_argument("--prompt")
    ap.add_argument("--file")
    ap.add_argument("--template")
    ap.add_argument("--requirements")
    ap.add_argument("--reqfile")
    ap.add_argument("--out")
    a = ap.parse_args()

    text = a.prompt
    if a.file:
        text = open(a.file, encoding="utf-8").read()
    if not text:
        raise SystemExit("need --prompt or --file")

    args = {"prompt": text}
    if a.template:
        args["template"] = a.template
    req = a.requirements
    if a.reqfile:
        req = open(a.reqfile, encoding="utf-8").read()
    if req:
        args["requirements"] = req

    out = call(a.tool, args)
    if a.out:
        open(a.out, "w", encoding="utf-8").write(out)
        print("wrote", a.out, len(out), "chars")
    else:
        print(out)


if __name__ == "__main__":
    main()
