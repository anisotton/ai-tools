# SKILL.md — dispatch

Decomposes a feature issue into sub-issues and assigns them to the right team members. Enforces that no task is created without the minimum quality fields.

## When to use

After receiving a feature issue from the superior and before any execution starts. Always use `get-team` first to know who is available and their specialties.

---

## Required fields per sub-issue

Every sub-issue created via dispatch **must** have all six fields. If any is missing, stop and resolve it before creating.

| Field | Purpose |
|-------|---------|
| `context` | Why this task exists — link to parent issue + relevant excerpt |
| `expected_result` | What must be delivered (concrete, verifiable) |
| `done_criteria` | How to know it's done — acceptance checklist |
| `dependencies` | What must be ready before this can start (explicit issue IDs or none) |
| `assignee` | Agent ID from `get-team` output — matched to task specialty |
| `project` | Project ID this task belongs to |

---

## Flow

### Step 1 — Understand the feature

Read the feature issue fully: scope, components, estimates, dependencies and acceptance criteria.

### Step 2 — Discover the team

Use `get-team` to get subordinates with name, ID and specialty. Match each planned subtask to the most appropriate team member.

### Step 3 — Decompose

Break the feature into the minimum number of subtasks that can be executed independently or in sequence. Prefer one clear task per agent over bundled tasks that create ambiguity.

### Step 4 — Validate

For each planned subtask, verify all six required fields are present and unambiguous. Missing or vague fields must be resolved before proceeding — never create an incomplete task.

### Step 5 — Create sub-issues

Create all sub-issues at once in Paperclip.

**Writing style:** Apply `caveman ultra` — maximum compression, abbreviations (DB, auth, fn, req), arrows for causality (X → Y). All content in **pt-BR**.

**Issue fields:**
- **title:** `[Task] <action verb> <scope> — <assignee name>`
- **status:** `open`
- **parent_id:** feature issue ID
- **assignee_agent_id:** agent ID from `get-team`
- **priority:** inherit from parent or set explicitly
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

1. **NEVER** create a sub-issue without all six required fields
2. **ALWAYS** use `get-team` before dispatching — never hardcode agent IDs
3. **ALWAYS** create all sub-issues at once — partial dispatch creates orphaned work
4. **ALWAYS** block the parent after dispatching — never leave it open while subtasks are running
5. **ALWAYS** write content in pt-BR using caveman ultra
6. **NEVER** dispatch to an agent whose specialty doesn't match the task — escalate to superior if no match
