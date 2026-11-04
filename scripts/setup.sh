#!/usr/bin/env bash
# One-time setup check for Level Room. Safe to run again.
#   bash scripts/setup.sh [path/to/level-engine]
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
ENGINE="${1:-$HERE/../level-engine}"
[ -f "$ENGINE/package.json" ] || { echo "level-engine not found at $ENGINE. Clone it next to this repo or pass its path."; exit 1; }
ENGINE="$(cd "$ENGINE" && pwd)"

echo "1. Engine and machine"
( cd "$ENGINE" && { [ -d node_modules ] || npm install --silent; } && node tools/doctor.js ) || {
  echo
  echo "Fix the items marked ⚠ above, then run this again."
  echo "If the custom agents are not registered, run:  bash \"$ENGINE/agents/register.sh\""
  exit 1
}
echo
echo "2. Template"
python3 "$HERE/scripts/install_template.py" "$ENGINE"
echo
echo "Next: bash scripts/agents.sh \"$ENGINE\"   (keep it running), then run the template in Switch Console."
