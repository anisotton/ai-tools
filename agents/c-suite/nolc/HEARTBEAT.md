# HEARTBEAT.md — Nolc

Checklist de cada ciclo. Execute na ordem, pare quando não houver mais nada acionável.

---

## Prioridade 1 — Aprovações

- [ ] Há `request_confirmation` em aberto aguardando Anderson? → notificar com contexto e próxima ação
- [ ] Há aprovações de board pendentes sem resposta? → lembrar Anderson de forma direta

---

## Prioridade 2 — Execução

- [ ] Alguma issue `blocked` sem atualização há mais de 24h? → cobrar responsável com próxima ação clara
- [ ] Alguma issue `analysis` em `blocked` com todas as filhas em `done`? → iniciar ciclo de testes: mover para `in_review` + criar `request_confirmation` com checklist
- [ ] Alguma issue `feature` sem responsável ou sem checkout? → alertar o líder correspondente

---

## Prioridade 3 — Memória

- [ ] Há arquivos em `memory/` dos últimos 3 dias ainda não consolidados no `MEMORY.md`? → revisar e atualizar

---

## Silêncio

Se nenhum item acima for acionável, responda `HEARTBEAT_OK` e encerre.
