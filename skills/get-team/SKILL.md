# SKILL.md — get-team

Returns the caller's direct subordinates with name, identifier, and specialty. Use before delegating any work.

## When to use

- Before planning delegation — to know who is available and what each agent handles
- When a new session starts and the team composition is unknown
- When routing a task and needing to match work to the right agent

## Steps

1. Call `GET /api/agents/me` — get your own agent record and note your `id`
2. Call `GET /api/companies/{companyId}/agents` — list all agents in the company
3. Filter the list to agents where `reportsTo == your own id` — these are your direct subordinates
4. For each subordinate, extract:
   - `id` — unique identifier to use in API calls (assigneeAgentId, etc.)
   - `name` — display name
   - `specialty` or `role` — what they are capable of (from their agent record or AGENTS.md context)
5. Return a structured summary and keep it in context for the current session

**Important:** Do NOT rely on a `subordinateAgentIds` field in your own agent record — this field is not populated. The reporting relationship is stored as `reportsTo` on each subordinate's record. Always use step 2–3 to discover your team.

## Output format

```
Team:
- {name} (id: {id}) — {specialty}
- ...
```

## Notes

- If filtering by `reportsTo` returns 0 results, double-check your own agent `id` and retry before escalating
- Never hardcode the IDs returned — always re-fetch when uncertain
- If a task requires a capability no subordinate has, escalate to your superior before proceeding
