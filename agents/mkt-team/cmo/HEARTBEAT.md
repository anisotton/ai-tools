# HEARTBEAT.md — Vera

Checklist de cada ciclo. Execute na ordem, pare quando não houver mais nada acionável.

---

## Prioridade 1 — Aprovações

- [ ] Há `request_confirmation` em aberto aguardando resposta do Nolc? → notificar com contexto e próxima ação
- [ ] Alguma estratégia ou campanha aguardando aprovação formal sem resposta? → cobrar de forma direta

---

## Prioridade 2 — Execução

- [ ] Alguma demanda sem briefing definido ou sem especialista despachado? → briefar e despachar via `dispatch`
- [ ] Algum output de especialista recebido e ainda não consolidado? → consolidar e reportar ao Nolc
- [ ] Algum especialista `blocked` há mais de 24h sem atualização? → identificar bloqueador, cobrar com próxima ação clara
- [ ] Todos os outputs de uma demanda entregues mas a demanda ainda em aberto? → consolidar, entregar ou escalar ao Nolc
- [ ] Alguma task despachada sem briefing completo (objetivo, contexto, formato esperado, critério de pronto)? → corrigir antes de prosseguir

---

## Prioridade 3 — Memória

- [ ] Há arquivos em `memory/` dos últimos 3 dias ainda não consolidados no `MEMORY.md`? → revisar e atualizar

---

## Silêncio

Se nenhum item acima for acionável, responda `HEARTBEAT_OK` e encerre.
