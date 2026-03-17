# claude-obsidian-thinker

A Claude Code plugin that keeps project context lightweight and persistent across sessions via Obsidian.

## What it does

- **`/closeout`** — At session end, Claude infers what happened and writes a structured entry to your Obsidian project note and daily log. Optionally creates knowledge notes for gotchas.
- **`/recall [topic]`** — Searches your vault for past knowledge about a repo or topic and surfaces it into the current session.
- **Stop hook** — Automatically runs closeout when the session ends (skips if `/closeout` already ran).
- **Recall skill** — Claude auto-triggers recall when it hits gnarly or familiar-looking problems.

## Installation

Inside Claude Code, add the marketplace and install:

```
/plugin marketplace add sam-phinizy/sams-claude-menagerie
/plugin install claude-obsidian-thinker@sams-claude-menagerie
```

Or install directly from this repo:

```
/plugin marketplace add sam-phinizy/claude-obsidian-thinker
/plugin install claude-obsidian-thinker@claude-obsidian-thinker
```

## Prerequisites

1. Obsidian 1.12+ with the CLI enabled (Settings → General → Command line interface)
2. `obsidian` on your PATH (the CLI registers this automatically)
3. `ripgrep` installed (`brew install ripgrep`)

## Setup

Copy the config template and set your vault path:

```bash
cp .claude/claude-obsidian-thinker.local.md /path/to/your/repo/.claude/claude-obsidian-thinker.local.md
```

Edit it:

```yaml
---
vault_path: ~/Documents/MyVault   # path to your Obsidian vault
projects_folder: Projects/         # folder for project notes
daily_folder: Daily/               # folder for daily logs
knowledge_folder: Knowledge/       # folder for gotcha/pattern notes
---
```

The `.local.md` file is gitignored — each developer sets their own vault path.

## Vault Structure

```
Projects/
  repo-name.md          # one note per project, newest-first entries

Daily/
  2026-03-16.md         # one file per day

Knowledge/
  iam-role-gotcha.md    # non-obvious bugs, patterns, workarounds
```

## Tag Taxonomy

All notes use aggressive YAML frontmatter tags in `namespace/value` format:

| Namespace | Example |
|-----------|---------|
| `project/` | `project/marketplace-state-data-store` |
| `repo/` | `repo/marketplace-state-data-store` |
| `domain/` | `domain/iam`, `domain/aws`, `domain/backend` |
| `type/` | `type/gotcha`, `type/pattern` |
| `status/` | `status/active`, `status/blocked` |

Claude infers and creates tags dynamically from session context.

## Usage

```
/closeout                        # infer project from git remote
/closeout billing-migration      # override project name
/recall                          # search by current repo name
/recall iam-role-inheritance     # search specific topic
```

## Future: V2 RAG

When the knowledge base grows large, add semantic search via Obsidian Bases (`base:query`) or a local embedding model over `Knowledge/`.
