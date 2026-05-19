---
name: test-browser
description: Configura, escreve e executa testes browser end-to-end em projetos do Lyra para validar navegabilidade, fluxos de usuário e comportamento visual. Suporta Laravel Dusk (PHP), Playwright (Node/Vue/React) e Cypress (Node/React). Use quando uma issue pede para criar, rodar ou diagnosticar testes de UI ou navegação.
compatibility: claude_local,codex_local
---

# Test Browser — Testes de Navegabilidade para Agentes

## O que você faz com esta skill

- Identificar o framework de testes pelo stack do projeto
- Verificar/instalar a infraestrutura de testes browser (Selenium, Playwright, Cypress)
- Escrever testes que simulam ações reais: cliques, formulários, navegação entre páginas
- Executar testes no Docker do Lyra com Chrome headless
- Interpretar falhas, capturar screenshots e reportar via Paperclip

---

## Passo 1 — Identificar stack e framework

```bash
# Ler stack do projeto
cat /home/anisotton/projects/{slug}/project.yml | grep stack
```

| Stack | Framework recomendado | Quando usar outro |
|---|---|---|
| Laravel (PHP) | **Laravel Dusk** | — |
| Node / Nuxt / Vue SSR | **Playwright** | Cypress se já estiver instalado |
| Node / Next.js / React | **Playwright** | Cypress se já estiver instalado |
| Qualquer (se Playwright já instalado) | **Playwright** | preferível por ser mais moderno |

---

## Infraestrutura Docker no Lyra (todos os frameworks)

Chrome/Selenium roda como container separado apenas durante testes. Não altere o `docker-compose.yml` principal.

### docker-compose.dusk.yml (override para testes)

```yaml
# /home/anisotton/projects/{slug}/docker-compose.dusk.yml
services:
  chrome:
    image: selenium/standalone-chrome:latest
    container_name: {slug}-chrome
    shm_size: 2g
    networks:
      - {slug}-internal

  app:
    environment:
      DUSK_DRIVER_URL: http://{slug}-chrome:4444
```

> Para Playwright e Cypress, o Chrome é gerenciado diretamente pelo framework (sem container Selenium).

### Subir/derrubar Chrome (para Dusk)

```bash
BASE="/home/anisotton/projects/{slug}"

docker compose -f $BASE/docker-compose.yml -f $BASE/docker-compose.dusk.yml up -d chrome

until docker compose -f $BASE/docker-compose.yml -f $BASE/docker-compose.dusk.yml \
  exec chrome curl -sf http://localhost:4444/status | grep -q '"ready":true'; do
  sleep 3
done

# Após os testes:
docker compose -f $BASE/docker-compose.yml -f $BASE/docker-compose.dusk.yml stop chrome
```

---

## Laravel Dusk (stack PHP/Laravel)

### Verificar instalação

```bash
BASE="/home/anisotton/projects/{slug}"
docker compose -f $BASE/docker-compose.yml exec app \
  composer show laravel/dusk 2>/dev/null && echo "INSTALADO" || echo "NAO_INSTALADO"
```

### Instalar (primeira vez)

```bash
docker compose -f $BASE/docker-compose.yml exec app composer require laravel/dusk --dev
docker compose -f $BASE/docker-compose.yml exec app php artisan dusk:install

# Criar .env.dusk.local no app/
cat > $BASE/app/.env.dusk.local << 'ENV'
APP_ENV=local
APP_DEBUG=true
APP_URL=http://127.0.0.1:8000
DUSK_DRIVER_URL=http://{slug}-chrome:4444
DB_CONNECTION=sqlite
DB_DATABASE=/var/www/html/database/dusk.sqlite
SESSION_DRIVER=array
CACHE_STORE=array
ENV

# Criar seeder isolado
docker compose -f $BASE/docker-compose.yml exec app php artisan make:seeder DuskSeeder
```

### Configurar DuskTestCase para Selenium remoto

Edite `app/tests/DuskTestCase.php`:

```php
protected function driver(): \Facebook\WebDriver\Remote\RemoteWebDriver
{
    $options = (new \Facebook\WebDriver\Chrome\ChromeOptions)->addArguments([
        '--headless=new', '--no-sandbox',
        '--disable-dev-shm-usage', '--window-size=1920,1080',
    ]);
    return \Facebook\WebDriver\Remote\RemoteWebDriver::create(
        env('DUSK_DRIVER_URL', 'http://localhost:9515'),
        \Facebook\WebDriver\Remote\DesiredCapabilities::chrome()
            ->setCapability(\Facebook\WebDriver\Chrome\ChromeOptions::CAPABILITY, $options),
        60000, 60000,
    );
}
```

### Executar testes Dusk

```bash
BASE="/home/anisotton/projects/{slug}"

# Preparar banco isolado
docker compose -f $BASE/docker-compose.yml exec app \
  php artisan migrate:fresh --seeder=DuskSeeder --env=dusk

# Todos os testes
docker compose -f $BASE/docker-compose.yml -f $BASE/docker-compose.dusk.yml \
  exec app php artisan dusk --env=dusk --verbose 2>&1

# Teste específico
docker compose -f $BASE/docker-compose.yml exec app \
  php artisan dusk tests/Browser/LoginTest.php --env=dusk

# Por grupo
docker compose -f $BASE/docker-compose.yml exec app \
  php artisan dusk --group=auth --env=dusk
```

### Escrever teste Dusk

```php
<?php
namespace Tests\Browser;

use Laravel\Dusk\Browser;
use PHPUnit\Framework\Attributes\Group;
use Tests\DuskTestCase;

#[Group('auth')]
class LoginTest extends DuskTestCase
{
    public function test_usuario_pode_fazer_login(): void
    {
        $this->browse(function (Browser $browser) {
            $browser->visit('/login')
                    ->waitForText('Entrar')
                    ->type('email', 'user@example.com')
                    ->type('password', 'password')
                    ->press('Entrar')
                    ->waitForLocation('/dashboard')
                    ->assertSee('Dashboard');
        });
    }

    public function test_login_invalido_mostra_erro(): void
    {
        $this->browse(function (Browser $browser) {
            $browser->visit('/login')
                    ->type('email', 'errado@example.com')
                    ->type('password', 'errado')
                    ->press('Entrar')
                    ->waitForText('credenciais')
                    ->assertSee('credenciais');
        });
    }
}
```

**Regras Dusk:**
- Use `waitFor*()` SEMPRE antes de asserções
- Prefira atributos `dusk="nome"` no HTML, referencie com `@nome` no teste
- Cada teste deve ser independente: dados via `DuskSeeder` ou factory

---

## Playwright (stack Node/Vue/React/Next)

### Verificar instalação

```bash
BASE="/home/anisotton/projects/{slug}"
docker compose -f $BASE/docker-compose.yml exec app \
  ls node_modules/.bin/playwright 2>/dev/null && echo "INSTALADO" || echo "NAO_INSTALADO"
```

### Instalar (primeira vez)

```bash
docker compose -f $BASE/docker-compose.yml exec app \
  npm install -D @playwright/test

docker compose -f $BASE/docker-compose.yml exec app \
  npx playwright install chromium --with-deps
```

### Arquivo de configuração playwright.config.ts

```typescript
// app/playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/browser',
  timeout: 30_000,
  fullyParallel: false,
  use: {
    baseURL: process.env.APP_URL || 'http://localhost:3000',
    headless: true,
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
});
```

### Executar testes Playwright

```bash
BASE="/home/anisotton/projects/{slug}"

# Todos os testes
docker compose -f $BASE/docker-compose.yml exec app \
  npx playwright test 2>&1

# Teste específico
docker compose -f $BASE/docker-compose.yml exec app \
  npx playwright test tests/browser/login.spec.ts

# Com relatório HTML
docker compose -f $BASE/docker-compose.yml exec app \
  npx playwright test --reporter=html
```

### Escrever teste Playwright

```typescript
// tests/browser/login.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Autenticação', () => {
  test('usuario pode fazer login', async ({ page }) => {
    await page.goto('/login');
    await page.waitForSelector('input[name="email"]');
    await page.fill('input[name="email"]', 'user@example.com');
    await page.fill('input[name="password"]', 'password');
    await page.click('button[type="submit"]');
    await page.waitForURL('/dashboard');
    await expect(page).toHaveTitle(/Dashboard/);
  });

  test('login invalido exibe erro', async ({ page }) => {
    await page.goto('/login');
    await page.fill('input[name="email"]', 'errado@example.com');
    await page.fill('input[name="password"]', 'errado');
    await page.click('button[type="submit"]');
    await expect(page.locator('.error-message')).toBeVisible();
  });
});
```

**Regras Playwright:**
- Use `waitForSelector` / `waitForURL` / `waitForLoadState` antes de agir
- Prefira `getByRole`, `getByLabel`, `getByTestId` para seletores acessíveis
- Screenshots e vídeos de falhas são salvos automaticamente em `test-results/`

---

## Cypress (stack Node/React — se já instalado)

### Verificar instalação

```bash
BASE="/home/anisotton/projects/{slug}"
docker compose -f $BASE/docker-compose.yml exec app \
  ls node_modules/.bin/cypress 2>/dev/null && echo "INSTALADO" || echo "NAO_INSTALADO"
```

### Executar testes Cypress (headless)

```bash
BASE="/home/anisotton/projects/{slug}"

docker compose -f $BASE/docker-compose.yml exec app \
  npx cypress run --headless --browser chromium 2>&1
```

### Escrever teste Cypress

```typescript
// cypress/e2e/login.cy.ts
describe('Autenticação', () => {
  it('usuario pode fazer login', () => {
    cy.visit('/login');
    cy.get('input[name="email"]').type('user@example.com');
    cy.get('input[name="password"]').type('password');
    cy.get('button[type="submit"]').click();
    cy.url().should('include', '/dashboard');
    cy.contains('Dashboard').should('be.visible');
  });
});
```

---

## Recuperar artefatos de falha

### Dusk — screenshots
```bash
docker cp {slug}-app:/var/www/html/tests/Browser/screenshots/ /tmp/{slug}-screenshots/
```

### Playwright — screenshots e vídeos
```bash
docker cp {slug}-app:/var/www/html/test-results/ /tmp/{slug}-test-results/
```

### Cypress — screenshots e vídeos
```bash
docker cp {slug}-app:/var/www/html/cypress/screenshots/ /tmp/{slug}-cypress-screenshots/
```

---

## Reportar resultados no Paperclip

Após executar, comente na issue com o modelo abaixo:

```md
## Testes Browser — Resultado

- **Framework:** Laravel Dusk / Playwright / Cypress
- **Status:** ✅ Passou / ❌ X falhas
- **Passaram:** X | **Falharam:** Y | **Tempo:** Zs

### Falhas
- `LoginTest::test_usuario_pode_fazer_login` — elemento `[dusk="submit"]` não encontrado após 5s
  - Causa provável: botão com condicional de loading não resolve antes do timeout

### Próximos passos
- [ ] Verificar condição de exibição do botão
- [ ] Aumentar timeout ou adicionar `waitFor` mais específico
```

---

## Troubleshooting

**Chrome/Selenium não conecta (Dusk)**
```bash
docker logs {slug}-chrome --tail=30
docker compose -f ... up -d chrome  # se parado
```

**Playwright não encontra Chromium**
```bash
docker compose exec app npx playwright install chromium --with-deps
```

**Banco SQLite não inicializa (Dusk)**
```bash
docker compose exec app touch database/dusk.sqlite
docker compose exec app php artisan migrate --env=dusk
```

**Variável de ambiente não carrega (Dusk)**
```bash
docker compose exec app php artisan tinker --env=dusk
>>> env('DUSK_DRIVER_URL')  # deve retornar http://{slug}-chrome:4444
```
