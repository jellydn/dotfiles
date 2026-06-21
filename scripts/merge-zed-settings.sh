#!/usr/bin/env bash
# Deep-merge Zed JSONC settings: repo base + optional ~/.config/zed/settings.local.json
# Zed does not load settings.local.json by itself — run this after editing local overrides.
#
# Usage:
#   ./scripts/merge-zed-settings.sh              # print merged JSONC to stdout
#   ./scripts/merge-zed-settings.sh --install    # write ~/.config/zed/settings.json (replaces symlink)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE="${ROOT}/common/.config/zed/settings.json"
LOCAL="${HOME}/.config/zed/settings.local.json"
OUT="${HOME}/.config/zed/settings.json"

merge_py() {
	local mode="${1:-print}"
	python3 - "$BASE" "$LOCAL" "$OUT" "$mode" <<'PY'
import json, re, sys
from pathlib import Path

def strip_jsonc(text: str) -> str:
    out = []
    i, n = 0, len(text)
    in_str = False
    esc = False
    while i < n:
        c = text[i]
        if in_str:
            out.append(c)
            if esc:
                esc = False
            elif c == "\\":
                esc = True
            elif c == '"':
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True
            out.append(c)
            i += 1
            continue
        if c == "/" and i + 1 < n and text[i + 1] == "/":
            while i < n and text[i] != "\n":
                i += 1
            continue
        out.append(c)
        i += 1
    s = "".join(out)
    s = re.sub(r",(\s*[}\]])", r"\1", s)
    return s

def load_jsonc(path: Path) -> dict:
    raw = path.read_text()
    return json.loads(strip_jsonc(raw))

def deep_merge(a: dict, b: dict) -> dict:
    out = dict(a)
    for k, v in b.items():
        if k in out and isinstance(out[k], dict) and isinstance(v, dict):
            out[k] = deep_merge(out[k], v)
        else:
            out[k] = v
    return out

base_path = Path(sys.argv[1])
mode = sys.argv[4] if len(sys.argv) > 4 else "print"
merged = load_jsonc(base_path)
local_arg = sys.argv[2]
if local_arg and Path(local_arg).is_file():
    merged = deep_merge(merged, load_jsonc(Path(local_arg)))

text = json.dumps(merged, indent="\t") + "\n"
if mode == "install":
    out_path = Path(sys.argv[3])
    out_path.parent.mkdir(parents=True, exist_ok=True)
    if out_path.is_symlink():
        out_path.unlink()
    elif out_path.exists():
        bak = out_path.with_suffix(".json.bak")
        bak.write_text(out_path.read_text())
        print(f"backup: {bak}", file=sys.stderr)
    out_path.write_text(text)
    print(f"wrote: {out_path}", file=sys.stderr)
else:
    sys.stdout.write(text)
PY
}

if [[ ! -f "$BASE" ]]; then
	echo "missing base: $BASE" >&2
	exit 1
fi

if [[ "${1:-}" == "--install" ]]; then
	merge_py install
else
	merge_py print
fi