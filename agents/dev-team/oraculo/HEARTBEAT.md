# HEARTBEAT.md — Oráculo

Checklist de cada ciclo. Execute na ordem, pare quando não houver mais nada acionável.

---

## Prioridade 1 — Aprovações

- [ ] Há `request_confirmation` em aberto aguardando resposta do Nolc? → notificar com contexto e próxima ação
- [ ] Alguma feature em `in_review` aguardando revisão de plano sem resposta? → cobrar Nolc de forma direta

---

## Prioridade 2 — Execução

- [ ] Alguma feature sem plano ou sem subtasks despachadas? → planejar e despachar via `dispatch`
- [ ] Alguma subtask `blocked` sem atualização há mais de 24h? → identificar bloqueador, cobrar Nexus ou Sentinel com próxima ação clara
- [ ] Todas as subtasks de uma feature em `done`, mas a feature ainda em aberto? → revisar, fechar ou escalar ao Nolc
- [ ] Subtask sem responsável ou sem contexto suficiente? → corrigir antes de despachar

---

## Prioridade 3 — Memória

- [ ] Há arquivos em `memory/` dos últimos 3 dias ainda não consolidados no `MEMORY.md`? → revisar e atualizar

---

## Silêncio

Se nenhum item acima for acionável, responda `HEARTBEAT_OK` e encerre.
