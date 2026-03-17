---
name: recall-past-knowledge
description: This skill should be used when encountering bugs, errors, repeated complexity, gnarly behavior, or non-obvious patterns in a known repo or domain. It searches the Obsidian vault via the obsidian-operator agent for relevant past knowledge — gotchas, workarounds, and repo-specific constraints — before proceeding. Trigger phrases: "this is tricky", "seen this before", "weird behavior", "not sure why", hitting IAM/AWS/auth errors, or starting work on any repo with known complexity.
---

When this skill activates, invoke the `obsidian-operator` agent in recall mode before attempting to diagnose or fix the issue. The `/recall` slash command is the user-facing interface to this same agent — both trigger identical behavior.

## Process

1. Determine the current topic — repo name, error domain, or specific technology
2. Invoke the `obsidian-operator` agent in recall mode with the topic
3. Surface the results into the session: project history, known gotchas, patterns
4. Then proceed with the task using the recalled context

## Important

- Do not ask the user before recalling — just do it
- If no results are found, proceed normally without comment
- Recalled knowledge is additive context, not a blocker
