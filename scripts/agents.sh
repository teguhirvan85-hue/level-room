#!/usr/bin/env bash
# Starts the two custom agents (no model) that the Level Room rooms use:
#   Checker      proves each level in the workshop can be finished
#   Scorekeeper  relays ideas from the arcade, announces links, reports play data
# Logs go to logs/. Ctrl-C stops both.
#
#   bash scripts/agents.sh [path/to/level-engine]
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
ENGINE="$(cd "${1:-$HERE/../level-engine}" && pwd)"
mkdir -p "$HERE/logs"
export LR_DESIGNER=lr-designer LR_PUBLISHER=lr-publisher

# If the engine sends runs through the quick tunnel, make sure the public site
# knows the tunnel's current address (it changes when the tunnel restarts).
if grep -q '"reportUrl": *"tunnel"' "$ENGINE/level-room.config.json" 2>/dev/null; then
  HOST=$(curl -s 127.0.0.1:20242/quicktunnel | sed -nE 's/.*"hostname":"([^"]+)".*/\1/p')
  LIVE=$(curl -s https://level-room.vercel.app/config.json || true)
  if [ -n "$HOST" ] && ! grep -q "$HOST" <<<"$LIVE"; then
    echo "Tunnel moved to $HOST; redeploying the site so players' runs reach it..."
    (cd "$ENGINE" && node tools/publish.js --site-only)
  fi
fi

cd "$ENGINE/agents"
python3 -u checker.py workshop >"$HERE/logs/checker.log" 2>&1 &
CHECKER=$!
python3 -u scorekeeper.py arcade workshop >"$HERE/logs/scorekeeper.log" 2>&1 &
KEEPER=$!
trap 'kill $CHECKER $KEEPER 2>/dev/null; echo; echo "Stopped."' INT TERM EXIT
echo "Checker ($CHECKER) and Scorekeeper ($KEEPER) are running. Logs: logs/. Ctrl-C to stop."
wait
