---
name: wakeup
description: Morning overview of all active projects. Reads yesterday's daily log and current project notes to give a prioritized summary of everything in flight and the best place to start.
allowed-tools: ["Bash", "Read"]
---

Give the user a morning briefing of all active projects so they can orient quickly after being away.

## Steps

1. **Read plugin config** from `.claude/claude-obsidian-thinker.local.md`. Extract `vault_path`, `projects_folder`, `daily_folder`. If missing, tell the user to create the config and stop.

2. **Find yesterday's daily log**:
```bash
obsidian read file="<YYYY-MM-DD>"  # yesterday's date
```
If yesterday's log doesn't exist, try the most recent daily log:
```bash
obsidian search query="type:daily"
```

3. **Extract active projects from the daily log** — find every project mentioned.

4. **Dispatch the `obsidian-operator` agent** in wakeup mode for each active project in parallel:
```
mode: wakeup
vault_path: <vault_path>
projects_folder: <projects_folder>
knowledge_folder: <knowledge_folder>
project: <project_name>
```

5. **Present the morning briefing** in this format:

```
# Morning Briefing — <today's date>

## Yesterday
<one sentence summary of what was happening across all projects>

---

## <Project Name>
**Status:** active | blocked
**Last done:** <done from most recent session>
**Next:** <next step>
**Blocked on:** <blocker, if any>
**Branch:** <branch, if any>

## <Project Name>
...

---

## Where to Start
<1-2 sentence recommendation on the best project to pick up first, based on recency, blockers, and momentum>
```

## Notes

- Show blocked projects but flag them clearly — don't recommend them as starting points unless all others are also blocked
- Sort projects by last-updated date, most recent first
- Keep each project summary to 4-5 lines max — this is an orientation tool, not a deep dive
- If no daily log is found for yesterday or recent days, read all project notes with `status: active` directly
