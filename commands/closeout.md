---
name: closeout
description: Close out the current work session by writing a summary to Obsidian. Updates the project note and daily log. Optionally accepts a project name to override auto-detection.
argument-hint: "[project-name]"
allowed-tools: ["Bash", "Read"]
---

Close out the current work session by inferring context from the conversation history and writing structured notes to Obsidian.

## Steps

1. **Read plugin config** from `.claude/claude-obsidian-thinker.local.md` in the current repo root. Extract `vault_path`, `projects_folder` (default: `Projects/`), `daily_folder` (default: `Daily/`), `knowledge_folder` (default: `Knowledge/`). If config is missing, tell the user to create it and stop.

2. **Determine project name**:
   - If an argument was passed to this command, use it as the project name
   - Otherwise, run `git remote get-url origin` and extract the repo name (last path segment, strip `.git`, normalize to lowercase-kebab-case)
   - If not in a git repo, ask the user for the project name

3. **Review the full conversation history** and extract:
   - `done`: A concise summary of what was accomplished this session
   - `next`: The clearest next step
   - `blocked`: Any blockers mentioned (or empty)
   - `branches`: Any git branches created or mentioned
   - `domains`: Tech domains touched (e.g., aws, iam, backend, postgres)
   - `gotcha`: Any non-obvious bugs, workarounds, or repo-specific patterns discovered (or empty)

4. **Dispatch the `obsidian-operator` agent** with this exact payload:

```
vault_path: <vault_path>
projects_folder: <projects_folder>
daily_folder: <daily_folder>
knowledge_folder: <knowledge_folder>
project: <project_name>
date: <YYYY-MM-DD>
time: <HH:MM>
done: <done>
next: <next>
blocked: <blocked>
branches: <branches>
domains: <domains>
gotcha: <gotcha>
session_source: command
```

5. **After the agent completes**, open the project note in Obsidian:
```bash
obsidian open file="<project_name>"
```

6. **Set session flag** to prevent duplicate writes if the Stop hook fires:
```bash
echo "closeout_ran" > /tmp/claude-obsidian-closeout-flag
```

## Notes

- Write notes in Obsidian even if Obsidian is not running — the CLI will launch it
- If `obsidian` is not on PATH, tell the user: "Obsidian CLI not found. Enable it in Obsidian Settings → General → Command line interface."
- Do not ask the user for confirmation before writing — just write it
