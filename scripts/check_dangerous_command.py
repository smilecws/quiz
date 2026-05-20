#!/usr/bin/env python3
"""PreToolUse hook: Bash 도구의 위험한 명령어를 차단한다.

Claude Code 가 stdin 으로 hook JSON payload 를 보낸다.
payload["tool_input"]["command"] 에서 위험 패턴을 찾으면 exit 2 로 차단한다.
"""
import json
import re
import sys

DANGEROUS = re.compile(
    r"rm\s+-rf|git\s+push\s+--force|git\s+reset\s+--hard|DROP\s+TABLE",
    re.IGNORECASE,
)


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0

    command = ""
    tool_input = payload.get("tool_input") if isinstance(payload, dict) else None
    if isinstance(tool_input, dict):
        command = tool_input.get("command", "") or ""

    if DANGEROUS.search(command):
        msg = "BLOCKED: 위험한 명령어가 감지되었습니다.\n".encode("utf-8")
        try:
            sys.stderr.buffer.write(msg)
            sys.stderr.buffer.flush()
        except AttributeError:
            sys.stderr.write(msg.decode("utf-8", errors="replace"))
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
