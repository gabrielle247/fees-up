#!/usr/bin/env bash
set -euo pipefail

# Convert numeric .withOpacity(x) -> .withAlpha(round(255*x)) in lib/*.dart
# Only transforms numeric literals; leaves variable expressions unchanged.

python3 - << 'PY'
import re
from pathlib import Path

root = Path('lib')
pattern = re.compile(r"\.withOpacity\(\s*([0-9]*\.?[0-9]+)\s*\)")

changed = 0
files = list(root.rglob('*.dart'))
for f in files:
    text = f.read_text(encoding='utf-8')
    def repl(m):
        try:
            val = float(m.group(1))
            a = max(0, min(255, round(255 * val)))
            return f".withAlpha({a})"
        except Exception:
            return m.group(0)
    new = pattern.sub(repl, text)
    if new != text:
        f.write_text(new, encoding='utf-8')
        changed += 1

print(f"Updated {changed} file(s).")
PY
