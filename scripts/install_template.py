#!/usr/bin/env python3
"""Saves level-room.yaml as the "Level Room" template on your local Switch
server, or updates it if it is already there. It acts through the Checker's
agent credentials (made by the engine's agents/register.sh), so no password is
needed here.

    python3 scripts/install_template.py [path/to/level-engine]
"""
from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
ENGINE = Path(sys.argv[1] if len(sys.argv) > 1 else HERE.parent / "level-engine").resolve()
sys.path.insert(0, str(ENGINE / "agents" / "lib"))
from switch_agent import SwitchAgent  # noqa: E402

NAME = "Level Room"
DESCRIPTION = "Anyone suggests a level in chat; it comes back checked and playable, and play data makes the next version better."


def run_op(agent: SwitchAgent, op: str, **arguments):
    # op() takes the operation as its own "name" argument, so templates
    # (which also have a "name") go through the raw call.
    resp = agent._call("POST", f"/agents/{agent.agent_id}/ops/{op}", arguments)
    return resp.get("result") if isinstance(resp, dict) else resp


def main() -> int:
    yaml = (HERE / "level-room.yaml").read_text()
    agent = SwitchAgent.from_name("level-checker")
    existing = agent.op("list_templates")
    items = existing.get("templates", existing) if isinstance(existing, dict) else existing
    match = next((t for t in items or [] if t.get("name") == NAME), None)
    if match:
        run_op(agent, "update_template", template_id=match["id"], yaml=yaml, description=DESCRIPTION)
        print(f'Updated the "{NAME}" template.')
    else:
        made = run_op(agent, "save_template", name=NAME, description=DESCRIPTION, yaml=yaml)
        print(f'Saved the "{NAME}" template ({(made or {}).get("id", "ok")}).')
    print("Open Switch Console > Templates > Level Room > Run, and pick your level-engine folder.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
