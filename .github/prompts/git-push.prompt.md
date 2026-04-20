---
description: "Stage all changes, commit with username and timestamp, and push to remote. Use when: committing, pushing, git push, stage and commit."
agent: "agent"
tools: [execute]
---

Run the following git commands in sequence in the terminal, stopping and reporting if any step fails:

1. Create and switch to a new branch named with the current timestamp:
```
git checkout -b "spark_branch_$(date '+%Y%m%d_%H%M%S')"
```

2. Stage all changes:
```
git add .
```

3. Commit with the git username and current timestamp as the message:
```
git commit -m "$(git config user.name) — $(date '+%Y-%m-%d %H:%M:%S')"
```

4. Push to remote:
```
git push -u origin HEAD
```

After each command, confirm it succeeded before proceeding to the next. Report the final status when done.
