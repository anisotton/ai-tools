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
| **HOW-TO** | Agent | Technical analysis, estimates, schedule, risks |

**Agent role:** Use `grill-me` to extract AS-IS and TO-BE from Anderson, then produce the HOW-TO and create structured issues in Paperclip using the available MCP tools.

---

## Issue Types

| Prefix | Created by | Purpose |
|--------|-----------|---------|
| `[Analysis]` | Leader | Parent issue — full DDP stored as document, tracks the entire initiative |
| `[Feature]` | Leader | One per team leader — contains relevant HOW-TO scope excerpt |

---

## Full Flow

### Step 1 — Discussion (grill-me)

Use the `grill-me` skill to interview Anderson one question at a time until AS-IS and TO-BE are fully understood.

- Ask questions one at a time
- Resolve each decision branch before moving to the next
- Provide your recommended answer for each question
- Only proceed to HOW-TO when AS-IS and TO-BE are complete and unambiguous

### Step 2 — Create Analysis Issue

**Before creating:** search for an existing issue with the same title using `paperclip_issues` action=`list`, `q="[Analysis] <title>"`. If a matching issue exists, do NOT create a duplicate — update the existing one instead.

Create the analysis issue using `paperclip_issues` action=`create`:

```
title:              "[Analysis] <short description>"
description:        One paragraph summary of the demand in pt-BR (caveman lite)
status:             "open"
assignee_agent_id:  own agent ID (from paperclip_agents action=get or context)
project_id:         resolved via paperclip_projects action=list
goal_id:            resolved via paperclip_goals action=list (if applicable)
priority:           "medium" (adjust based on urgency)
```

**Store the full DDP** using `paperclip_documents` action=`upsert`:
```
issue_id: <created issue ID>
key:      "ddp"
title:    "DDP — <short description>"
body:     Full DDP content in pt-BR, caveman lite (see DDP Template below)
```

**Then create the approval** using `paperclip_approvals` action=`create`:
```
type:                   "request_confirmation"
issue_ids:              [<created issue ID>]
requested_by_agent_id:  own agent ID
```

**Then update the issue status** using `paperclip_issues` action=`update`:
```
issue_id: <created issue ID>
status:   "in_review"
```

**Do not proceed to Step 3 until Anderson approves the request_confirmation.**

### Step 3 — Create Feature Issues

After Anderson's formal approval, create **all feature issues at once** — one per team leader involved.

**Before creating:** call `paperclip_agents action=list` to fetch the current agent roster and resolve each leader's ID by name. **Never** use the project's `leadAgentId` as a substitute — it may be null or wrong. If you cannot resolve a leader's ID from the list, stop and ask Anderson before creating the issue.

Use `paperclip_issues` action=`create` for each feature issue:

```
title:              "[Feature] <scope description> — <Leader name>"
description:        Relevant HOW-TO excerpt for that leader's scope in pt-BR, caveman ultra
status:             "open"
parent_id:          analysis issue ID
goal_id:            inherited from analysis issue
project_id:         same as analysis issue
assignee_agent_id:  leader agent ID resolved from paperclip_agents action=list (REQUIRED — never omit)
priority:           inherit from analysis issue
```

### Step 4 — Block Analysis

After all feature issues are created, update the analysis issue using `paperclip_issues` action=`update`:
```
issue_id:              analysis issue ID
status:                "blocked"
blocked_by_issue_ids:  [array of all feature issue IDs]
comment:               "Blocked — waiting for feature issues: #ID1, #ID2, ..."
```

### Step 5 — Monitor and Request Testing

When **all feature issues reach `done`**:

1. Retrieve test data by running `php artisan tinker` or querying the project database for relevant test users and credentials
2. Build a test checklist from the HOW-TO acceptance criteria in the DDP document
3. Update the analysis issue: `paperclip_issues` action=`update`, `status: "in_review"`
4. Create a new approval using `paperclip_approvals` action=`create` with the test checklist and data in the payload

### Step 6 — Close

After Anderson approves the test confirmation:
```
paperclip_issues action=update
  issue_id: analysis issue ID
  status:   "done"
  comment:  closing summary in pt-BR
```

---

## DDP Template (stored in document key "ddp")

All content must be written in **Brazilian Portuguese (pt-BR)** using caveman lite (remove filler, keep full sentences and grammar).

```markdown
## AS-IS

### Processo atual
[Descrição do estado atual]

### Fluxos existentes
[Como as coisas funcionam hoje]

### Problemas / Gargalos
[O que está quebrado ou ineficiente]

---

## TO-BE

### Objetivos
[Metas SMART]

### Escopo
[Lista de entregáveis]

### Regras de negócio
[Regras que governam o novo comportamento]

---

## HOW-TO

### Tecnologias envolvidas

| Tecnologia | Versão | Propósito |
|------------|--------|-----------|
| [Linguagem/Framework] | [Versão] | [Uso] |

### Arquitetura proposta

#### Visão geral
[Descrição da arquitetura]

#### Fluxo de dados
[Como os dados transitam entre componentes]

### Decomposição de features

#### Módulo/Componente 1
- **Feature:** [Nome]
- **Descrição:** [O que faz]
- **Regras aplicadas:** [Referência às regras de negócio do TO-BE]
- **Estimativa:** [X horas/dias]
- **Responsável:** [Nome do líder]

### Plano de integração

| Sistema | Tipo de integração | Protocolo | Notas |
|---------|--------------------|-----------|-------|
| [Sistema] | [API/Webhook/DB] | [REST/etc] | [Notas] |

### Estimativa de esforço

| Fase | Atividade | Esforço |
|------|-----------|---------|
| Desenvolvimento | [Componente] | X horas |
| Testes | [Tipo de teste] | X horas |
| Deploy | [Atividades] | X horas |
| **Total** | | **X horas** |

### Cronograma proposto

| Marco | Data alvo | Entregável |
|-------|-----------|------------|
| Início | [Data] | Kickoff |
| Entrega 1 | [Data] | [O quê] |
| Entrega final | [Data] | [Escopo completo] |

### Riscos e dependências

| Risco/Dependência | Impacto | Mitigação |
|-------------------|---------|-----------|
| [Descrição] | Alto/Médio/Baixo | [Ação] |

### Critérios de aceite
- [ ] Critério 1
- [ ] Critério 2

### Premissas
- [Premissa 1]
```

---

## Feature Issue Description Template

Content in **pt-BR**, caveman ultra — maximum compression, abbreviations (DB, auth, fn, req), arrows for causality (X → Y).

```markdown
## Escopo

[Trecho relevante do HOW-TO para a área deste líder]

## Componentes / Módulos

- **[Componente 1]:** [Descrição] — Estimativa: X horas
- **[Componente 2]:** [Descrição] — Estimativa: X horas

## Critérios de aceite
- [ ] Critério 1
- [ ] Critério 2

## Dependências
- [Issue de análise #ID]
- [Outras dependências]

## Riscos
- [Riscos relevantes para este escopo]
```

---

## Rules

1. **NEVER** produce the HOW-TO without complete AS-IS and TO-BE from Anderson
2. **NEVER** create a feature issue before Anderson formally approves the analysis via approval
3. **NEVER** create an issue without first checking for duplicates with `paperclip_issues` action=`list`
4. **ALWAYS** store the full DDP in a document (`paperclip_documents` action=`upsert`, key=`"ddp"`) — never in the description
5. **ALWAYS** use MCP tools (`paperclip_issues`, `paperclip_approvals`, `paperclip_documents`) — never raw HTTP calls
6. **ALWAYS** create all feature issues at once after approval
7. **ALWAYS** resolve leader agent IDs via `paperclip_agents action=list` before creating feature issues — **NEVER** omit `assignee_agent_id`, even if the project has no `leadAgentId` configured
8. **ALWAYS** set analysis to `blocked` with `blocked_by_issue_ids` after creating feature issues
9. **ALWAYS** use `request_confirmation` approvals for both gates (analysis and testing)
10. **ALWAYS** pull test data from the project database — never hardcode credentials
11. **ALWAYS** write all issue content in pt-BR (description caveman lite for analysis, caveman ultra for features)

---

## Integration with Leader Workflow

After feature issues are created (`open`), each leader:
1. Reads their feature issue description for scope and context
2. Uses `dispatch` skill to decompose into sub-issues for their team
3. Updates feature issue to `blocked` while waiting for sub-issues
4. Closes feature issue when all sub-issues are `done`
