---
name: pickup
description: Deep dive on a specific project to get fully up to speed before starting work. Reads the project note, recent session history, relevant knowledge notes, and git state.
argument-hint: "<project>"
allowed-tools: ["Bash", "Read"]
---

Get the user fully oriented on a specific project so they can start working immediately with no lost context.

## Steps

1. **Read plugin config** from `.claude/claude-obsidian-thinker.local.md`. Extract `vault_path`, `projects_folder`, `knowledge_folder`. If missing, tell the user to create the config and stop.

2. **Determine project name**:
   - Use the argument if provided: `/pickup billing-migration`
   - Otherwise infer from `git remote get-url origin` → extract repo name
   - If not in a git repo and no argument given, ask the user

3. **Gather context in parallel**:

   **A. Dispatch `obsidian-operator` in recall mode** for the project:
   ```
   mode: recall
   vault_path: <vault_path>
   projects_folder: <projects_folder>
   knowledge_folder: <knowledge_folder>
   topic: <project_name>
   ```

   **B. Check git state**:
   ```bash
   git branch --show-current
   git log --oneline -5
   git stash list
   git status --short
   ```

4. **Present the pickup briefing** in this format:

```
# Picking Up: <project>

## Where You Left Off
**Last session:** <date and time of most recent session entry>
**Done:** <what was finished>
**Next:** <the next step — this is what to do first>
**Blocked on:** <blocker if any>
**Branch:** <current or last branch>

## Recent History
<last 2-3 session entries, brief>

## Git State
**Branch:** <current branch>
**Last commits:**
<last 3 commits oneline>
<stashed work if any>
<uncommitted changes if any>

## Known Gotchas
<relevant knowledge notes for this project — gotchas, patterns, constraints>

## Start Here
<one clear sentence: the exact first thing to do>
```

## Notes

- "Start Here" is the most important part — make it specific and actionable, not vague
- If there are uncommitted changes or stashed work, always surface them — the user may have forgotten
- If the project note doesn't exist yet, say so and offer to create it with `/closeout` after the first session
- Keep "Known Gotchas" brief — bullet points only, link to the full knowledge note by name
