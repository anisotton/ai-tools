# SKILL.md — dispatch

Decomposes a feature issue into sub-issues and assigns them to the right team members. Enforces that no task is created without the minimum quality fields.

## When to use

After receiving a feature issue from the superior and before any execution starts. Always use `get-team` first to know who is available and their specialties.

---

## Required fields per sub-issue

Every sub-issue created via dispatch **must** have all seven fields. If any is missing, stop and resolve it before creating.

| Field | Purpose |
|-------|---------|
| `context` | Why this task exists — link to parent issue + relevant excerpt |
| `expected_result` | What must be delivered (concrete, verifiable) |
| `done_criteria` | How to know it's done — acceptance checklist |
| `dependencies` | What must be ready before this can start (explicit issue IDs or "none") |
| `assignee` | Agent ID from `get-team` output — matched to task specialty |
| `project` | Project ID this task belongs to |
| `goal_id` | Inherited from the parent feature issue — preserves strategic traceability |

---

## Flow

### Step 1 — Understand the feature

Read the feature issue fully: scope, components, estimates, dependencies, acceptance criteria and `goal_id`.

### Step 2 — Discover the team

Use `get-team` to get subordinates with name, ID and specialty. Match each planned subtask to the most appropriate team member.

### Step 3 — Decompose

Break the feature into the minimum number of subtasks that can be executed independently or in sequence. Prefer one clear task per agent over bundled tasks that create ambiguity.

For sequential tasks, map the execution order explicitly — task B depends on task A means B must have A's issue ID in its `blocked_by_issue_ids`.

### Step 4 — Validate

For each planned subtask, verify all seven required fields are present and unambiguous.

If a field is missing:
- **Can be inferred from the feature issue context?** → fill it and note the inference in the sub-issue body
- **Cannot be inferred?** → stop, comment on the feature issue with the specific gap, set status to `blocked`, and escalate to the superior before proceeding

Never create a sub-issue with a vague or empty required field.

### Step 5 — Create sub-issues

Create all sub-issues at once in Paperclip.

**Writing style:** Apply `caveman ultra` — maximum compression, abbreviations (DB, auth, fn, req), arrows for causality (X → Y). All content in **pt-BR**.

**Issue fields:**
- **title:** `[Task] <action verb> <scope> — <assignee name>`
- **tag:** `task`
- **status:** `open`
- **priority:** inherit from parent — override only when this specific task has different urgency than the feature
- **parent_id:** feature issue ID
- **goal_id:** inherited from feature issue
- **assignee_agent_id:** agent ID from `get-team`
- **blocked_by_issue_ids:** IDs of other sub-issues this task depends on (if sequential)
- **body:** see template below

### Step 6 — Block the parent

After all sub-issues are created, update the feature issue:
- **status:** `blocked`
- **blocked_by_issue_ids:** array of all sub-issue IDs just created
- **comment:** `Decomposto em N subtasks: #ID1, #ID2, ... Aguardando execução.`

---

## Sub-issue body template

```markdown
## Contexto
[Por que essa task existe — ref. à issue pai + trecho relevante do escopo]

## Resultado esperado
[O que deve ser entregue — concreto e verificável]

## Critérios de pronto
- [ ] Critério 1
- [ ] Critério 2

## Dependências
- [#ID de outra issue ou "nenhuma"]
```

---

## Rules

1. **NEVER** create a sub-issue without all seven required fields
2. **ALWAYS** use `get-team` before dispatching — never hardcode agent IDs
3. **ALWAYS** create all sub-issues at once — partial dispatch creates orphaned work
4. **ALWAYS** block the parent after dispatching — never leave it open while subtasks are running
5. **ALWAYS** inherit `goal_id` from the parent feature issue
6. **ALWAYS** set `blocked_by_issue_ids` between sub-issues when there is a sequential dependency
7. **ALWAYS** write content in pt-BR using caveman ultra
8. **NEVER** dispatch to an agent whose specialty doesn't match the task — escalate to superior if no match
