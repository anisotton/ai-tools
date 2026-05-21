# SKILL.md — get-team

Returns the caller's direct subordinates with name, identifier, and specialty. Use before delegating any work.

## When to use

- Before planning delegation — to know who is available and what each agent handles
- When a new session starts and the team composition is unknown
- When routing a task and needing to match work to the right agent

## Steps

1. Call `GET /api/agents/me` — get your own agent record
2. From the response, identify agents that report directly to you (subordinates list or equivalent field)
3. For each subordinate, extract:
   - `id` — unique identifier to use in API calls (assigneeAgentId, etc.)
   - `name` — display name
   - `specialty` or `role` — what they are capable of (from their agent record)
4. Return a structured summary and keep it in context for the current session

## Output format

```
Team:
- {name} (id: {id}) — {specialty}
- ...
```

## Notes

- If no subordinates are returned, report to your superior — team may not be configured
- Never hardcode the IDs returned — they are valid for the current session only; always re-fetch when uncertain
- If a task requires a capability no subordinate has, escalate to your superior before proceeding
