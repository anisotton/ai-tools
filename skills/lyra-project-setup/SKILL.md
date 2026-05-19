---
name: lyra-project-setup
description: Use when initializing or updating a codebase project on the Lyra server. Receives slug + github_repo, auto-detects stack and runtime versions from project files (composer.json, package.json, etc.), creates folder structure, docker-compose + Traefik config + Makefile + project.yml, .env with random passwords, brings containers up, and creates/updates the Paperclip project. Idempotent — re-runs only update configs, never touch app/ code or .env.
compatibility: Runs on Lyra host (no SSH). Requires PAPERCLIP_API_KEY env var (auto-injected when invoked as Paperclip agent), git, curl, jq, docker, openssl, write access to /opt/traefik/dynamic/
metadata:
  author: isotton-corp
  version: "3.2"
---

# Lyra Project Setup (v3)

Inicializa ou atualiza um projeto de código da Isotton Corp no servidor Lyra, seguindo a convenção padrão. Idempotente — pode rodar quantas vezes precisar; nunca toca no código (`app/`) nem sobrescreve `.env` existente.

## Inputs

Extraia da conversa com o usuário:

- `slug` (obrigatório) — nome curto do projeto. Ex: `smasy`
- `github_repo` (obrigatório) — `org/repo` ou URL. Ex: `IsottonCorp/smasy` ou `https://github.com/IsottonCorp/smasy`

Se faltar, **pergunte antes de prosseguir**. Não invente valores.

## Variáveis fixas

- `COMPANY_ID=c282c1b4-cc48-404d-a349-b89e776b79b8`
- `PAPERCLIP_API=http://127.0.0.1:3100`
- `BASE_DIR=/home/anisotton/projects/${slug}`
- `SKILL_DIR=~/.paperclip/instances/default/companies/${COMPANY_ID}/codex-home/skills/lyra-project-setup`
- `TRAEFIK_DIR=/opt/traefik/dynamic`

## Procedimento

### 1. Normalizar github_repo

```bash
GITHUB_REPO=$(echo "$github_repo" | sed -E "s|^https?://github\.com/||" | sed "s|\.git$||")
GITHUB_OWNER=$(echo "$GITHUB_REPO" | cut -d/ -f1)
GITHUB_NAME=$(echo "$GITHUB_REPO" | cut -d/ -f2)
GITHUB_URL="https://github.com/${GITHUB_REPO}"
```

### 2. Buscar metadata do GitHub

```bash
GH_META=$(curl -s "https://api.github.com/repos/${GITHUB_REPO}")
DISPLAY_NAME=$(echo "$GH_META" | jq -r ".name // empty")
DESCRIPTION=$(echo "$GH_META" | jq -r ".description // empty")

[ -z "$DISPLAY_NAME" ] && DISPLAY_NAME="$(echo "$slug" | sed "s/.*/\u&/")"
[ -z "$DESCRIPTION" ] || [ "$DESCRIPTION" = "null" ] && DESCRIPTION="Projeto ${slug}"
```

### 3. Detectar MODE (create ou update)

```bash
if [ -f "${BASE_DIR}/project.yml" ]; then
  MODE=update
  PAPERCLIP_PROJECT_ID=$(grep "^  project_id:" "${BASE_DIR}/project.yml" | awk "{print \$2}")
  CREATED_AT=$(grep "^created_at:" "${BASE_DIR}/project.yml" | awk "{print \$2}")
else
  MODE=create
  CREATED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
fi
UPDATED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
```

### 4. Se MODE=create — criar estrutura e clonar repo

```bash
if [ "$MODE" = create ]; then
  mkdir -p "${BASE_DIR}/app" "${BASE_DIR}/data/logs" "${BASE_DIR}/data/storage"

  if [ ! "$(ls -A ${BASE_DIR}/app 2>/dev/null)" ]; then
    if ! git clone "git@github.com:${GITHUB_REPO}.git" "${BASE_DIR}/app" 2>&1; then
      echo "WARN: clone falhou — app/ vazio. Continuando."
    fi
  fi
fi
```

### 5. Detectar stack e versão de runtime

```bash
STACK=
if [ -f "${BASE_DIR}/app/composer.json" ]; then
  STACK=laravel
elif [ -f "${BASE_DIR}/app/package.json" ]; then
  STACK=node
elif [ -f "${BASE_DIR}/app/requirements.txt" ] || [ -f "${BASE_DIR}/app/pyproject.toml" ]; then
  STACK=python
fi
```

Se `STACK` ficou vazio ou se há mais de uma stack detectada (ex: composer.json E package.json), **pergunte ao usuário** qual stack usar entre `laravel | node | python`.

Detectar versão de runtime a partir dos arquivos do projeto:

```bash
RUNTIME_VERSION=
case "$STACK" in
  laravel)
    # Lê campo require.php do composer.json (ex: ">=8.4.0" → "8.4")
    PHP_CONSTRAINT=$(jq -r '.require.php // empty' "${BASE_DIR}/app/composer.json" 2>/dev/null)
    RUNTIME_VERSION=$(echo "$PHP_CONSTRAINT" | grep -oP '\d+\.\d+' | sort -V | tail -1)
    [ -z "$RUNTIME_VERSION" ] && RUNTIME_VERSION="8.3"
    ;;
  node)
    # Lê campo engines.node do package.json (ex: ">=20.0.0" → "20")
    NODE_CONSTRAINT=$(jq -r '.engines.node // empty' "${BASE_DIR}/app/package.json" 2>/dev/null)
    RUNTIME_VERSION=$(echo "$NODE_CONSTRAINT" | grep -oP '\d+' | head -1)
    # Fallback: arquivo .nvmrc ou .node-version
    [ -z "$RUNTIME_VERSION" ] && RUNTIME_VERSION=$(cat "${BASE_DIR}/app/.nvmrc" 2>/dev/null | grep -oP '\d+' | head -1)
    [ -z "$RUNTIME_VERSION" ] && RUNTIME_VERSION="20"
    ;;
  python)
    # Lê campo tool.poetry.dependencies.python ou python_requires do pyproject.toml
    RUNTIME_VERSION=$(grep -oP 'python\s*=\s*["']\^?>=?\K[\d.]+' "${BASE_DIR}/app/pyproject.toml" 2>/dev/null | head -1)
    [ -z "$RUNTIME_VERSION" ] && RUNTIME_VERSION=$(grep -oP 'python_requires.*>=\K[\d.]+' "${BASE_DIR}/app/setup.py" 2>/dev/null | head -1)
    [ -z "$RUNTIME_VERSION" ] && RUNTIME_VERSION=$(cat "${BASE_DIR}/app/runtime.txt" 2>/dev/null | grep -oP '[\d.]+' | head -1)
    [ -z "$RUNTIME_VERSION" ] && RUNTIME_VERSION="3.12"
    ;;
esac
```

### 6. Defaults por stack

```bash
case "$STACK" in
  laravel) DATABASE=mysql;    APP_PORT=80 ;;
  node)    DATABASE=postgres; APP_PORT=3000 ;;
  python)  DATABASE=postgres; APP_PORT=8000 ;;
esac

mkdir -p "${BASE_DIR}/data/${DATABASE}"
[ "$STACK" = laravel ] && mkdir -p "${BASE_DIR}/data/redis"
```

### 7. Montar payload do projeto Paperclip

```bash
PAYLOAD=$(jq -n \
  --arg name "$DISPLAY_NAME" \
  --arg desc "$DESCRIPTION" \
  --arg url "https://${slug}.lyra" \
  --arg repo "$GITHUB_URL" \
  --arg stack "$STACK" \
  --arg db "$DATABASE" \
  "{
    name: \$name,
    description: \$desc,
    env: {
      APP_URL: \$url,
      GITHUB_REPO: \$repo,
      STACK: \$stack,
      DATABASE: \$db
    }
  }")

CREATE_PAYLOAD=$(echo "$PAYLOAD" | jq \
  --arg repo "$GITHUB_URL" \
  --arg cwd "${BASE_DIR}/app" \
  --arg slug "$slug" \
  ". + {
    workspace: {
      isPrimary: true,
      name: \$slug,
      sourceType: \"git_repo\",
      repoUrl: \$repo,
      defaultRef: \"main\",
      cwd: \$cwd
    }
  }")
```

### 8. Criar ou atualizar o projeto Paperclip

**Se MODE=create:**

```bash
RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$CREATE_PAYLOAD" \
  "${PAPERCLIP_API}/api/companies/${COMPANY_ID}/projects")

PAPERCLIP_PROJECT_ID=$(echo "$RESPONSE" | jq -r ".id // empty")
if [ -z "$PAPERCLIP_PROJECT_ID" ]; then
  echo "ERRO: criação do projeto Paperclip falhou: $RESPONSE"
  exit 1
fi
```

**Se MODE=update:**

```bash
curl -s -X PATCH \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "${PAPERCLIP_API}/api/projects/${PAPERCLIP_PROJECT_ID}" > /dev/null
```

### 9. Renderizar templates locais

Função helper:

```bash
render() {
  local src=$1 dst=$2
  sed -e "s|{{SLUG}}|${slug}|g" \
      -e "s|{{DISPLAY_NAME}}|${DISPLAY_NAME}|g" \
      -e "s|{{DESCRIPTION}}|${DESCRIPTION}|g" \
      -e "s|{{GITHUB_REPO}}|${GITHUB_REPO}|g" \
      -e "s|{{STACK}}|${STACK}|g" \
      -e "s|{{DATABASE}}|${DATABASE}|g" \
      -e "s|{{APP_PORT}}|${APP_PORT}|g" \
      -e "s|{{PAPERCLIP_PROJECT_ID}}|${PAPERCLIP_PROJECT_ID}|g" \
      -e "s|{{CREATED_AT}}|${CREATED_AT}|g" \
      -e "s|{{RUNTIME_VERSION}}|${RUNTIME_VERSION}|g" \
      -e "s|{{UPDATED_AT}}|${UPDATED_AT}|g" \
      "$src" > "$dst"
}

render "${SKILL_DIR}/templates/${STACK}/docker-compose.yml" "${BASE_DIR}/docker-compose.yml"
render "${SKILL_DIR}/templates/${STACK}/Makefile"           "${BASE_DIR}/Makefile"
render "${SKILL_DIR}/templates/${STACK}/.env.example"       "${BASE_DIR}/.env.example"
render "${SKILL_DIR}/templates/project.yml.tpl"             "${BASE_DIR}/project.yml"
render "${SKILL_DIR}/templates/traefik.yml.tpl"             "${TRAEFIK_DIR}/${slug}.yml"

# Copiar arquivos de conf extras (ex: nginx customizado para cada stack)
if [ -d "${SKILL_DIR}/templates/${STACK}/conf" ]; then
  mkdir -p "${BASE_DIR}/conf"
  cp "${SKILL_DIR}/templates/${STACK}/conf/"* "${BASE_DIR}/conf/"
fi
```

**Garantias:** Nunca renderize para `${BASE_DIR}/.env`. Nunca toque em `${BASE_DIR}/app/`.

### 10. Gerar .env (MODE=create e .env inexistente)

Gera `.env` com senhas aleatórias seguras. **Nunca sobrescreve `.env` existente.**

```bash
if [ "$MODE" = create ] && [ ! -f "${BASE_DIR}/app/.env" ]; then
  DB_PASS=$(openssl rand -hex 16)
  DB_ROOT_PASS=$(openssl rand -hex 16)

  cp "${BASE_DIR}/.env.example" "${BASE_DIR}/app/.env"

  # Substituir valores placeholder por senhas geradas
  sed -i "s|DB_PASSWORD=changeme|DB_PASSWORD=${DB_PASS}|g" "${BASE_DIR}/app/.env"
  sed -i "s|DB_ROOT_PASSWORD=changeme|DB_ROOT_PASSWORD=${DB_ROOT_PASS}|g" "${BASE_DIR}/app/.env"

  # Laravel: gerar APP_KEY
  if [ "$STACK" = laravel ]; then
    APP_KEY="base64:$(openssl rand -base64 32)"
    sed -i "s|APP_KEY=|APP_KEY=${APP_KEY}|g" "${BASE_DIR}/app/.env"
  fi

  echo "INFO: .env gerado com senhas aleatórias."
fi
```

### 11. Subir containers e inicializar app (MODE=create)

Sobe os containers somente na primeira execução. Em re-execuções (MODE=update), não interfere com o estado dos containers.

```bash
if [ "$MODE" = create ]; then
  cd "${BASE_DIR}"

  # Garantir estrutura completa do storage antes de subir (Laravel)
  if [ "$STACK" = laravel ]; then
    mkdir -p "${BASE_DIR}/data/storage/app/public"
    mkdir -p "${BASE_DIR}/data/storage/framework/cache/data"
    mkdir -p "${BASE_DIR}/data/storage/framework/sessions"
    mkdir -p "${BASE_DIR}/data/storage/framework/views"
    mkdir -p "${BASE_DIR}/data/storage/logs"
  fi

  echo "INFO: Subindo containers..."
  docker compose up -d

  # Aguardar app container ficar running (max 60s)
  echo "INFO: Aguardando ${slug}-app..."
  for i in $(seq 1 12); do
    STATUS=$(docker inspect --format='{{.State.Status}}' "${slug}-app" 2>/dev/null)
    if [ "$STATUS" = "running" ]; then
      echo "INFO: ${slug}-app está running."
      break
    fi
    sleep 5
  done

  # Laravel: build assets frontend (host tem Node, container não tem)
  if [ "$STACK" = laravel ] && [ -f "${BASE_DIR}/app/package.json" ]; then
    echo "INFO: Buildando assets Vite/npm..."
    cd "${BASE_DIR}/app"
    npm ci --prefer-offline 2>&1 | tail -3
    npm run build 2>&1 | tail -5
    cd "${BASE_DIR}"
  fi

  # Laravel: instalar dependências e inicializar app
  if [ "$STACK" = laravel ]; then
    echo "INFO: Rodando composer install..."
    docker exec "${slug}-app" composer install --no-interaction --prefer-dist --optimize-autoloader 2>&1 | tail -3

    echo "INFO: Aguardando banco de dados..."
    sleep 10

    echo "INFO: Rodando migrations..."
    docker exec "${slug}-app" php artisan migrate --force 2>&1 | tail -5 || echo "WARN: migrate falhou — verificar manualmente."

    echo "INFO: Criando storage link..."
    docker exec "${slug}-app" php artisan storage:link 2>&1

    echo "INFO: Cacheando config..."
    docker exec "${slug}-app" php artisan config:cache 2>&1
  fi
fi
```

### 12. Reportar resultado

Mostre ao usuário:

```
✓ Projeto {slug} {criado|atualizado}

URL:        https://{slug}.lyra
Repo:       https://github.com/{github_repo}
Paperclip:  https://dashboard.lyra/ISO/projects/{slug}
Path:       /home/anisotton/projects/{slug}/
Stack:      {stack} + {database}
Containers: {status dos containers}
```

## Garantias de Idempotência

| Recurso | 1ª execução (create) | Re-execução (update) |
|---|---|---|
| Pastas | Cria | `mkdir -p` (no-op) |
| `app/` (código) | `git clone` | **Nunca toca** |
| `paperclip_project_id` | Cria via POST | Preservado do `project.yml` |
| Projeto Paperclip | POST | PATCH (atualiza) |
| `docker-compose.yml` | Gera | Regenera |
| Traefik config | Gera | Regenera |
| `project.yml` | Gera | Regenera (preserva `created_at` e `project_id`) |
| `Makefile` | Gera | Regenera |
| `.env.example` | Gera | Regenera |
| `.env` | **Gera com senhas aleatórias** | **Nunca toca** |
| Storage dirs | Cria subpastas framework | **Não toca** |
| Containers | `docker compose up -d` | **Não interfere** |
| `composer install` | Roda no container | **Não roda** |
| Migrations | `artisan migrate --force` | **Não roda** |
| `storage:link` | Cria symlink | **Não roda** |
| `config:cache` | Cacheia config | **Não roda** |
