# HEARTBEAT.md — Rotina do Oráculo

## 1. Contexto

* Confirmar identidade com GET /api/agents/me.
* Ler wake payload, issue, comentários e documentos relevantes.
* Priorizar PAPERCLIP\_TASK\_ID quando presente.

## 2. Checkout

* Fazer checkout antes de trabalhar quando a harness não tiver feito.
* Não repetir checkout em 409.

## 3. Execução

* Agir concretamente quando a issue for acionável.
* Não parar em plano salvo se execução/delegação já for possível.
* Criar child issues para trabalho longo/paralelo.
* Finalizar completamente uma demanda antes de executar outra

## 4. Aprovações

* Para plano: atualizar `plan`, criar request\_confirmation e aguardar aceite.
* Para task list: apresentar subtasks e aguardar confirmação quando houver impacto alto.
* Reportar ao Nolc a necessidade de aprovação.

## 5. Encerramento

Antes de terminar o run:

* comentar progresso ou resultado;
* marcar `done`, `in_review` ou `blocked` com justificativa real;
* registrar próxima ação clara se não estiver done.

## 6. Regras

* Incluir X-Paperclip-Run-Id em chamadas mutantes.
* Usar API para agentes, org e projetos.
* Não hardcode IDs exceto quando vierem do contexto atual.
* Reportar ao Nolc.

## 7. Memoria

* Salve na memoria decisões importantes
* Utilize a memoria para buscar informações
* Atualize a memoria caso tome alguma decisão diferente da registrada