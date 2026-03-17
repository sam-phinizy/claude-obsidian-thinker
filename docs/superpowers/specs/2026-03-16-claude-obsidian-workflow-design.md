# Claude–Obsidian Workflow Plugin Design

**Date:** 2026-03-16
**Status:** Draft

---

## Overview

A Claude Code plugin that keeps project context lightweight and persistent across sessions. When a session ends, Claude infers what happened from history and writes structured notes into an Obsidian vault. When a session starts on a known repo, Claude can recall relevant past knowledge on demand or automatically.

---

## Prerequisites

This plugin requires the **Obsidian CLI** — the official CLI shipped with Obsidian 1.12+ (enabled via Settings → General → Command line interface). The `obsidian` binary must be on `$PATH`. See [Obsidian CLI docs](https://help.obsidian.md/cli) for installation.

The Obsidian app must be running for CLI commands to execute.

---

## Vault Structure

```
Projects/
  auth-refactor.md
  marketplace-state-data-store.md

Daily/
  2026-03-16.md

Knowledge/
  iam-role-inheritance-gotcha.md
  marketplace-state-data-store-patterns.md
```

### Frontmatter Schema

**Project notes:**

```yaml
---
project: marketplace-state-data-store
type: project
status: active         # active | blocked | complete
tags:
  - project/marketplace-state-data-store
  - repo/marketplace-state-data-store
  - domain/aws
  - domain/iam
  - status/active
last-updated: 2026-03-16
---
```

**Knowledge notes** — `project` is optional (set to triggering project, or omitted if cross-project):

```yaml
---
type: knowledge
project: marketplace-state-data-store   # optional
tags:
  - repo/marketplace-state-data-store
  - domain/aws
  - domain/iam
  - type/gotcha
last-updated: 2026-03-16
---
```

### Tag Namespace Convention

Tags follow a `namespace/value` pattern. Claude infers and creates tags dynamically — the namespaces are the only fixed convention:

| Namespace | Purpose |
|-----------|---------|
| `project/<name>` | Which project this belongs to |
| `repo/<name>` | Git repo name |
| `domain/<name>` | Tech domain (aws, iam, backend, etc.) |
| `type/<name>` | Note type (gotcha, pattern, blocked, etc.) |
| `status/<name>` | Current status |

Tags are written aggressively. Claude infers domains and types from session context.

### Status Transitions

Sonnet sets `status` based on the session summary:

| Condition | Status |
|-----------|--------|
| Blocker mentioned in session | `blocked` |
| Work described as finished/complete | `complete` |
| All other cases | `active` |

### Project Note Format

Entries are prepended (newest-first) so the most recent session is always at the top:

```markdown
---
[frontmatter]
---

## 2026-03-16 17:30
Done: Finished JWT middleware
Next: Add SecurityAudit hook
Blocked: Waiting on role inheritance decision
Branch: feat/auth-security-audit

## 2026-03-15 16:00
Done: Scaffolded middleware
Next: Write JWT validation logic
```

### Daily Log Format

```markdown
# 2026-03-16

- marketplace-state-data-store: fixed IAM role lookup; next add audit hook; blocked on role inheritance decision
- auth-refactor: finished JWT middleware; next SecurityAudit hook
```

---

## Configuration

Stored per-machine in `.claude/claude-obsidian-thinker.local.md` at the repo root. This file is gitignored (`.local.` naming convention) and machine-specific — each developer sets their own vault path.

```yaml
---
vault_path: ~/Documents/MyVault
projects_folder: Projects/
daily_folder: Daily/
knowledge_folder: Knowledge/
---
```

If no config is found, the plugin prompts the user to set `vault_path` before proceeding.

---

## Plugin Components

### 1. `/closeout [project?]` Slash Command

Invoked manually at any point during or at the end of a session.

**Project name resolution:**
1. Use argument if provided: `/closeout billing-migration`
2. Otherwise infer from `git remote get-url origin` — extract repo name, normalize to lowercase-kebab-case
3. If not in a git repo, prompt user for project name
4. If inferred name matches no existing project note, create one

**Behavior:**
- Sonnet reviews session history and extracts: what was done, what's next, blockers, branches touched, domains/services involved
- Sonnet decides whether any knowledge-worthy patterns or gotchas were encountered (see Knowledge Note Criteria below)
- Dispatches a Haiku subagent to handle all Obsidian CLI operations
- After Haiku completes, opens the updated project note: `obsidian open file="<project>"`
- Sets a session flag to prevent duplicate writes if the Stop Hook fires afterward

**Haiku subagent responsibilities:**

```bash
# 1. Create project note if it doesn't exist
obsidian create name="<project>" content="<frontmatter-only>"
# (no-op if file exists — use overwrite only on first create)

# 2. Prepend timestamped entry (newest-first)
obsidian prepend file="<project>" content="<entry>"

# 3. Update frontmatter properties
obsidian property:set name=status value=<status> file="<project>"
obsidian property:set name=last-updated value=<date> file="<project>"

# 4. Append to daily note (CLI creates it if missing)
obsidian daily:append content="- <project>: <one-liner>"

# 5. If knowledge note needed: create and tag
obsidian create name="<slug>" content="<content>"
obsidian property:set name=tags value="[...]" file="<slug>"
obsidian property:set name=type value=knowledge file="<slug>"
obsidian property:set name=last-updated value=<date> file="<slug>"
```

**Knowledge Note Criteria:**

Sonnet should flag content as knowledge-worthy when the session involved:
- A non-obvious bug fix or workaround
- A repo-specific pattern or constraint (e.g., "this repo always requires X before Y")
- A gotcha that required significant debugging time
- A reusable pattern discovered during the session

Routine work (feature implementation, standard refactors) does not warrant a knowledge note.

### 2. Stop Hook

Registered in `.claude/settings.json` as a `stop` lifecycle hook. Fires automatically when the Claude session ends.

```json
{
  "hooks": {
    "stop": ["<plugin-root>/hooks/closeout.sh"]
  }
}
```

**Behavior:**
- Checks session flag — if `/closeout` was already run this session, exits without writing (prevents duplicate entries)
- Otherwise runs identical logic to `/closeout` but silently — no note is opened in Obsidian

### 3. `/recall [topic?]` Slash Command

Invoked manually to pull past knowledge into context.

**Behavior:**
- Without argument: uses current git repo name as topic
- With argument: `/recall iam-role-inheritance`
- Dispatches a Haiku subagent to search in parallel

**Haiku subagent search strategy:**

Runs both searches in parallel, merges results, deduplicates by file path:

```bash
# Search 1: ripgrep (fast, regex, works if Obsidian is not running)
# Searches both Knowledge/ and Projects/ folders
rg "<topic>" ~/vault/Knowledge/ ~/vault/Projects/ -l
rg "<topic>" ~/vault/Knowledge/ ~/vault/Projects/ -C 3

# Search 2: Obsidian CLI (semantic, tag-aware, alias-aware)
obsidian search:context query="<topic>"
obsidian search:context query="repo/<topic>"
```

Sonnet receives merged results and summarizes relevant context into the session.

### 4. Recall Skill (Auto-trigger)

A Claude Code skill that Claude invokes automatically when it encounters a familiar or complex problem.

**Skill description (trigger):**
> Use when encountering bugs, errors, repeated complexity, or gnarly behavior in a known repo or domain — search the Obsidian vault for relevant past knowledge before proceeding.

**Behavior:** Same Haiku subagent and search strategy as `/recall`, triggered by Claude's own judgment rather than user invocation.

---

## Agent Responsibilities

| Agent | Responsibility |
|-------|---------------|
| Sonnet | Infers context, decides what happened, writes note content, flags knowledge-worthy items, dispatches Haiku |
| Haiku | Runs all Obsidian CLI commands, ripgrep searches, property setting, tagging, deduplication |

---

## Error Handling

| Failure | Behavior |
|---------|---------|
| `obsidian` not on PATH | Abort with message: "Obsidian CLI not found. See setup instructions." |
| Vault path not configured | Prompt user to set `vault_path` in config |
| Vault path does not exist | Abort with message including the configured path |
| Obsidian not running | First CLI command launches Obsidian automatically (CLI behavior) |
| `ripgrep` not installed | Fall back to `obsidian search:context` only, log warning |
| Git repo not found | Prompt user for project name |

---

## Future: V2 RAG

When the knowledge base grows large enough that keyword search misses things, add semantic search via:
- Obsidian Bases (`base:query`) for structured queries
- A local embedding model over the `Knowledge/` folder

For now, parallel ripgrep + `obsidian search:context` is sufficient and zero infrastructure.

---

## What This Solves

| Problem | Solution |
|---------|---------|
| Losing context at session end | Stop hook writes automatically |
| Slow restart next day | Project note always has current state at top |
| Forgetting repo-specific gotchas | Knowledge notes, recalled on demand or automatically |
| End-of-day reporting | Daily log updated every session |
| Finding past knowledge | Parallel ripgrep + Obsidian search, merged results |
| Duplicate writes | Session flag prevents Stop Hook from writing if `/closeout` already ran |
