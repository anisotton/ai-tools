
## 2026-05-14 — Paperclip/OpenClaw onboarding
- Conectado ao Paperclip via invite `pcp_invite_a64ycx4w` como agente `Nolc`.
- Agent ID criado/aprovado: `c3993ef0-278d-47fe-8df3-2d861b754aed`.
- Paperclip API local: `https://dashboard.lyra` (mapeado em `/etc/hosts` para `192.168.1.50`).
- OpenClaw gateway local: porta IPv4 `18789`; proxy IPv6 persistente via systemd user em `18790`.
- Adapter URL cadastrado: `ws://[2804:4d98:260:4300:523e:aaff:fe75:77a5]:18790/`.
- API key do Paperclip salva em `~/.openclaw/workspace/paperclip-claimed-api-key.json` (modo 600).
- Skill Paperclip instalado em `~/.openclaw/skills/paperclip/SKILL.md`.

## 2026-05-14 — Objetivos estratégicos Isotton no Paperclip
- Goal principal criado: `590a718a-0928-4df4-aa4a-e49d71dab318` — Atingir 100 usuários ativos nas plataformas até jan/2027.
- Goals filhos criados:
  - `2efb480b-4e87-421f-878c-d7363ef799fa` — Estruturar projetos SaaS completos.
  - `732dbcb8-d223-4698-a007-dfc17c99cf08` — Lançar projetos SaaS completos.
  - `6221d069-0154-42a4-b94e-b4e87e99f771` — Ativar e reter usuários nas plataformas.
- Decisão estratégica: todo projeto SaaS estratégico deve ser pensado por pilares: produto/DEV, marca/MKT, operação/onboarding/suporte, aquisição/growth e métricas/aprendizado.

## 2026-05-18 — Estrutura organizacional de agentes
- Anderson decidiu estruturar equipe antes de avançar no diagnóstico SaaS completo.
- Nolc acumula PM estratégico/Chief of Staff no curto prazo.
- Oráculo permanece como Líder do Dev-Squad.
- Criadas no backlog do projeto Onboarding:
  - ISO-10 — Estruturar e criar agente Líder de People / Agent Ops.
  - ISO-11 — Estruturar e criar agente Líder de Growth.
- Ordem conceitual: People / Agent Ops antes de Growth, para criar padrão de desenho/criação de agentes.

## 2026-05-18 — ISO-12 smasy testes particionada
- ISO-12 foi concluída no escopo de orquestração: subtasks criadas para o ciclo Dev-Squad sem pular o líder Oráculo.
- ISO-16 — Nexus via Oráculo: implementar/corrigir suíte de testes — smasy — assignee Oráculo (`2616f60a-8cc0-4390-8831-25aa9dcda39e`).
- ISO-17 — Sentinel via Oráculo: validar suíte de testes e E2E — smasy — assignee Oráculo, bloqueada por ISO-16.
- IDs relevantes: Nexus `d3b2a962-a0cd-47f4-a006-e6bb6fa63ab4`; Sentinel `b8960e19-e8a5-4b71-bd58-4badd52799c9`; Oráculo `2616f60a-8cc0-4390-8831-25aa9dcda39e`.

## 2026-05-20 — Preferencia de idioma
- O usuario prefere conversar em portugues do Brasil (pt-BR). Manter respostas concisas e amigaveis quando possivel.

## Promoted From Short-Term Memory (2026-05-24)

<!-- openclaw-memory-promotion:memory:memory/2026-05-20.md:3:3 -->
- - 13:22 UTC — Usuario pediu para falar em portugues e salvar a preferencia nas memorias. Preferencia registrada: portugues do Brasil (pt-BR), com estilo conciso e amigavel. [score=0.835 recalls=0 avg=0.620 source=memory/2026-05-20.md:3-3]
<!-- openclaw-memory-promotion:memory:memory/2026-05-20.md:5:5 -->
- - 02:58 UTC — Anderson solicitou tema escuro fixo na home do projeto isotton. Decisões: seguir recomendação do Nolc; escopo somente rota `/`; não alterar visual das páginas carmasy/smasy; prosseguir via fluxo DDP antes de issue/execução. [score=0.835 recalls=0 avg=0.620 source=memory/2026-05-20.md:5-5]
