---
name: report-bug
description: This skill should be used when encountering unexpected behavior, errors, or failures caused by the claude-obsidian-thinker plugin itself — including broken Obsidian CLI commands, malformed note output, hook failures, recall returning bad results, or any plugin component not behaving as documented. Do not trigger for user configuration issues or Obsidian/ripgrep not being installed. Trigger phrases: "this isn't working", "the plugin broke", "closeout didn't write anything", "the hook didn't fire", "recall returned nothing", or any stack trace or error from a plugin command or agent.
---

When this skill activates, file a GitHub issue for the bug using the `gh` CLI.

## Process

1. **Gather bug details** from the current conversation:
   - What command or component failed (`/closeout`, `/recall`, `/wakeup`, `/pickup`, Stop hook, obsidian-operator agent)
   - What the user expected to happen
   - What actually happened (error message, wrong output, no output)
   - Relevant context: OS, vault path format, git repo state

2. **Check `gh` is available**:
```bash
which gh && gh auth status
```
If `gh` is not installed or not authenticated, give the user the issue URL instead:
`https://github.com/sam-phinizy/claude-obsidian-thinker/issues/new`

3. **File the issue**:
```bash
gh issue create \
  --repo sam-phinizy/claude-obsidian-thinker \
  --title "<concise bug title>" \
  --body "$(cat <<'EOF'
## What happened
<description of the failure>

## Expected behavior
<what should have happened>

## Component
<which command/agent/hook>

## Context
<relevant details: OS, vault path, git state, error output>

## Reported by
claude-obsidian-thinker report-bug skill
EOF
)"
```

4. **Tell the user** the issue URL that was created.

## Important

- Only file issues for bugs in the plugin itself, not for Obsidian CLI errors, missing config, or ripgrep not being installed — those are setup issues
- Do not file duplicate issues — if the user says this has happened before, note it in the issue body
- Keep the title short and specific: "closeout: prepend fails when project note doesn't exist" not "plugin broken"
