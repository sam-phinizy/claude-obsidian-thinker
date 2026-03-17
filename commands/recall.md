---
name: recall
description: Search the Obsidian vault for past knowledge relevant to the current repo or a given topic. Pulls in project history, gotchas, and patterns into the current session context.
argument-hint: "[topic]"
allowed-tools: ["Bash", "Read"]
---

Search the Obsidian vault for past knowledge and surface it into the current session context.

## Steps

1. **Read plugin config** from `.claude/claude-obsidian-thinker.local.md`. Extract `vault_path`, `projects_folder`, `knowledge_folder`. If missing, tell the user to create the config and stop.

2. **Determine search topic**:
   - If an argument was passed, use it as the topic
   - Otherwise, infer from current git repo name: `git remote get-url origin` → extract repo name

3. **Dispatch the `obsidian-operator` agent** in search mode with this payload:

```
mode: recall
vault_path: <vault_path>
projects_folder: <projects_folder>
knowledge_folder: <knowledge_folder>
topic: <topic>
```

4. **Receive results** from the agent — a merged, deduplicated list of relevant notes with key excerpts.

5. **Summarize findings** into the session context in this format:

```
## Recalled: <topic>

### Project History
<summary of recent sessions from project note>

### Known Gotchas
<list of relevant gotchas from knowledge notes>

### Patterns
<any relevant patterns or constraints>
```

If nothing relevant is found, say: "No past knowledge found for '<topic>'. This may be a new project or topic."

## Notes

- This command injects knowledge into the current conversation — it does not modify any files
- Use `/recall` at the start of a session on a familiar repo to get up to speed fast
- Use `/recall <topic>` when hitting a tricky problem to see if you've seen it before
