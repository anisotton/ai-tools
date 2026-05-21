---
name: workflow-demand-analysis
description: Technical analysis of demands following the DDP model — receives AS-IS and TO-BE via discussion with Anderson, produces HOW-TO and creates structured issues in Paperclip. Use when discussing a new feature, analyzing a demand, or creating a HOW-TO with estimates and risks.
compatibility:
  - opencode
  - claude-code
  - github-copilot
---

# Workflow Demand Analysis (DDP)

## Context

The DDP is composed of three parts:

| Document | Owner | Content |
|----------|-------|---------|
| **AS-IS** | Anderson | Current process, existing flows, problems |
| **TO-BE** | Anderson | Desired project, scope, business rules |
| **HOW-TO** | Nolc (Agent) | Technical analysis, estimates, schedule, risks |

**Agent role:** Use `grill-me` to extract AS-IS and TO-BE from Anderson, then produce the HOW-TO and create structured issues in Paperclip.

---

## Issue Types

| Tag | Created by | Purpose |
|-----|-----------|---------|
| `analysis` | Nolc | Parent issue — full DDP content, tracks the entire initiative |
| `feature` | Nolc | One per team leader — contains relevant HOW-TO scope excerpt |
| `bug` | — | Different model, defined separately |

---

## Full Flow

### Step 1 — Discussion (grill-me)

Use the `grill-me` skill to interview Anderson one question at a time until AS-IS and TO-BE are fully understood.

- Ask questions one at a time
- Resolve each decision branch before moving to the next
- Provide your recommended answer for each question
- Only proceed to HOW-TO when AS-IS and TO-BE are complete and unambiguous

### Step 2 — Create Analysis Issue

Once the discussion is complete, create the `analysis` issue in Paperclip.

**Writing style:** Apply `caveman lite` — remove filler and hedging, keep full sentences and grammar. All content must be written in **Brazilian Portuguese (pt-BR)**.

**Issue fields:**
- **title:** `[Analysis] <short description>`
- **tag:** `analysis`
- **status:** `in_review`
- **body:** Full DDP content in pt-BR, caveman lite (see Output Structure below)

Then immediately create a **`request_confirmation`** in Paperclip pointing to this issue for Anderson's formal approval.

**Do not proceed to Step 3 until Anderson approves the request_confirmation.**

### Step 3 — Create Feature Issues

After Anderson's formal approval, create **all feature issues at once** — one per team leader involved.

**Writing style:** Apply `caveman ultra` — maximum compression, abbreviations (DB, auth, fn, req, res), arrows for causality (X → Y). All content must be written in **Brazilian Portuguese (pt-BR)**.

**Issue fields:**
- **title:** `[Feature] <scope description> — <Leader name>`
- **tag:** `feature`
- **status:** `open`
- **parent_id:** analysis issue ID
- **body:** Relevant HOW-TO excerpt for that leader's scope in pt-BR, caveman ultra (components, estimates, risks, done criteria)

### Step 4 — Block Analysis

After all feature issues are created, update the analysis issue:
- **status:** `blocked`
- **comment:** `Blocked — waiting for feature issues to complete: #ID1, #ID2, ...`

### Step 5 — Monitor and Request Testing

Monitor child feature issues via Paperclip API. When **all feature issues reach `done`**:

1. Query project database via `php artisan` to retrieve relevant test users and credentials
2. Build a test checklist from the HOW-TO acceptance criteria
3. Update analysis issue status to `in_review`
4. Create a **`request_confirmation`** with:
   - Test checklist (one item per acceptance criterion)
   - Test data (users, passwords, URLs pulled from DB/seeders)
   - Environment details

### Step 6 — Close

After Anderson approves the test `request_confirmation`:
- Update analysis issue **status:** `done`
- Add closing comment summarizing what was delivered

---

## Output Structure (Analysis Issue Body)

```markdown
## AS-IS

### Current Process
[Description of the current state]

### Existing Flows
[How things work today]

### Problems / Bottlenecks
[What is broken or inefficient]

---

## TO-BE

### Objectives
[SMART goals]

### Scope
[Deliverables list]

### Business Rules
[Rules that govern the new behavior]

---

## HOW-TO

### Technologies Involved

| Technology | Version | Purpose |
|------------|---------|---------|
| [Language/Framework] | [Version] | [Usage] |

### Proposed Architecture

#### Overview
[Architecture description]

#### Component Diagram
[Diagram or component description]

#### Data Flow
[How data moves between components]

### Feature Breakdown

#### Module/Component 1
- **Feature:** [Name]
- **Description:** [What it does]
- **Rules applied:** [Reference to TO-BE business rules]
- **Estimate:** [X hours/days]
- **Owner:** [Leader name]

### Integration Plan

| System | Integration Type | Protocol | Notes |
|--------|-----------------|----------|-------|
| [System] | [API/Webhook/DB] | [REST/etc] | [Notes] |

### Effort Estimate

| Phase | Activity | Effort |
|-------|----------|--------|
| Development | [Component] | X hours |
| Testing | [Test type] | X hours |
| Deployment | [Activities] | X hours |
| **Total** | | **X hours** |

### Proposed Schedule

| Milestone | Target Date | Deliverable |
|-----------|-------------|-------------|
| Start | [Date] | Kickoff |
| Delivery 1 | [Date] | [What] |
| Final Delivery | [Date] | [Full scope] |

### Risks and Dependencies

| Risk/Dependency | Impact | Mitigation |
|-----------------|--------|------------|
| [Description] | High/Medium/Low | [Action] |

### Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

### Assumptions
- [Assumption 1]
```

---

## Feature Issue Body Template

```markdown
## Scope

[Relevant excerpt from HOW-TO for this leader's area]

## Components / Modules

- **[Component 1]:** [Description] — Estimate: X hours
- **[Component 2]:** [Description] — Estimate: X hours

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Dependencies
- [Analysis issue #ID]
- [Other dependencies]

## Risks
- [Relevant risks for this scope]
```

---

## Test Request Template (request_confirmation)

```markdown
## Manual Testing Request

All feature issues are complete. Please validate the following:

### Test Checklist
- [ ] [Criterion 1 from HOW-TO]
- [ ] [Criterion 2 from HOW-TO]

### Test Data
| Field | Value |
|-------|-------|
| URL | [environment URL] |
| User | [from DB/seeder] |
| Password | [from DB/seeder] |
| Role | [user role] |

### Notes
[Any relevant context for testing]
```

---

## Rules

1. **NEVER** produce the HOW-TO without complete AS-IS and TO-BE from Anderson
2. **NEVER** create feature issues before Anderson formally approves the analysis via `request_confirmation`
3. **ALWAYS** create all feature issues at once after approval
4. **ALWAYS** include the relevant HOW-TO excerpt in each feature issue body
5. **ALWAYS** set analysis to `blocked` after creating feature issues
6. **ALWAYS** use `request_confirmation` for both approval gates (analysis and testing)
7. **ALWAYS** pull test data from the project database via `php artisan` — never hardcode credentials
8. **ALWAYS** extract test checklist from the HOW-TO acceptance criteria
9. **ALWAYS** write analysis issue content in pt-BR using caveman lite
10. **ALWAYS** write feature issue content in pt-BR using caveman ultra

---

## Integration with Leader Workflow

After feature issues are created (`open`), each leader:
1. Reads their feature issue body for scope and context
2. Uses their `dispatch` skill to decompose into sub-issues for their team
3. Updates feature issue to `blocked` while waiting for sub-issues
4. Closes feature issue when all sub-issues are `done`
