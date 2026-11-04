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

cd "$ENGINE/agents"
python3 -u checker.py workshop >"$HERE/logs/checker.log" 2>&1 &
CHECKER=$!
python3 -u scorekeeper.py arcade workshop >"$HERE/logs/scorekeeper.log" 2>&1 &
KEEPER=$!
trap 'kill $CHECKER $KEEPER 2>/dev/null; echo; echo "Stopped."' INT TERM EXIT
echo "Checker ($CHECKER) and Scorekeeper ($KEEPER) are running. Logs: logs/. Ctrl-C to stop."
wait
