#!/usr/bin/env python3
import json, sys

event = json.load(sys.stdin)
tool  = event.get("tool_name", "")
inp   = event.get("tool_input", {})

EDIT_TOOLS = {
    "str_replace_in_file", "multi_str_replace_in_file",
    "create_file", "write_file", "replace_string_in_file",
    "insert_edit_into_file", "delete_file"
}

if tool not in EDIT_TOOLS:
    sys.exit(0)

path = inp.get("path", inp.get("filePath", "")).replace("\\", "/")
if "validations/" in path:
    sys.exit(0)

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": (
            f"access-auditor agent may only write to validations/. "
            f"Attempted path: {path}"
        )
    }
}))
sys.exit(2)
