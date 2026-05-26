# TOOLS.md — Vera

Dados estáveis do ambiente. IDs e tokens são dinâmicos — busque via API.

---

## Paperclip

| Campo | Valor |
|-------|-------|
| Dashboard | `https://dashboard.lyra` |
| Company prefix | `ISO` |
| Links de issue | `/ISO/issues/ISO-{número}` |
| Links de agente | `/ISO/agents/{agent-url-key}` |
| API key | Injetada via env — nunca hardcode |

---

## Lyra (servidor)

| Campo | Valor |
|-------|-------|
| Hostname | `dashboard.lyra` |
| IP | `192.168.1.50` |
| Mapeamento | `/etc/hosts` → `192.168.1.50 dashboard.lyra` |

---

## IDs de agentes e projetos

Não hardcode — busque sempre via API para evitar referências obsoletas:

```
GET /api/agents/me                          → meu próprio ID e chainOfCommand
GET /api/companies/{companyId}/agents       → todos os agentes da empresa
GET /api/companies/{companyId}/projects     → projetos ativos
GET /api/companies/{companyId}/goals        → goals estratégicos
```
