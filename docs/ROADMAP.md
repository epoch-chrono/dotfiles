# Roadmap

Documento vivo do projeto. Estado atual, próximas fatias planejadas e direção de
longo prazo. Atualizado conforme decisões são tomadas.


## Estado atual

Versão do playbook: `0.17.0`.

### Bootstrap

- `bootstrap.sh` minimal (sh-only, ~30 linhas) — instala git, curl, fish, chezmoi
- Pré-req: `TARGET_HOSTNAME` exportado, `python3` disponível
- Roda Ansible local (connection: local), sem SSH em loop nem inventário multi-host
- Idempotente: re-rodar não muda nada se nada divergiu


### Auth GitHub PAT

Mise instala ~90 tools baixando releases do GitHub. Sem token: 60 req/h
por IP, bate rate limit e quebra o install no meio. Com token: 5000+ req/h.

#### Como o token entra no playbook

`bootstrap.sh` exige `GITHUB_API_TOKEN` env var (similar a `TARGET_HOSTNAME`)
em todo run. Sem ela, o script falha antes de fazer side effects.

A role `chezmoi` propaga essa env var via `environment:` na task
`Mise — instalar tools` (como `GITHUB_API_TOKEN` E `GITHUB_TOKEN` —
mise resolve por uma das duas).

```fish
# Em todo run (cold start, steady state, recovery):
set -gx GITHUB_API_TOKEN ghp_xxxxxxxxxxxx
set -gx TARGET_HOSTNAME macv2-0x564a520a
bash -c "$(curl -fsSL https://raw.githubusercontent.com/epoch-chrono/dotfiles/main/bootstrap.sh)"
```

Em SSH remoto:

```sh
ssh mac-novo "bash -c \"
  export TARGET_HOSTNAME=macv2-0x564a520a;
  export GITHUB_API_TOKEN=ghp_xxxxxxxxxxxx;
  git -C \$HOME/.local/share/dotfiles pull origin main &&
  \$(curl -fsSL https://raw.githubusercontent.com/epoch-chrono/dotfiles/main/bootstrap.sh)\""
```

#### Como gerar o PAT

1. https://github.com/settings/tokens/new
2. Description: `mise-github-api`
3. Expiration: 1 ano (rotacionar anualmente)
4. **Scopes: TUDO desmarcado** — least privilege. Pra repos públicos
   (todos os tools que mise instala), autenticação anônima-com-identidade
   já dá rate limit elevado. Zero blast radius extra.
5. Generate token → copia `ghp_...`

#### Onde guardar (one-time, pós-primeiro-bootstrap)

```fish
# 1P.app já instalado pela role homebrew. Faça signin manual + habilite
# CLI integration em Settings → Developer.
op item create --category 'API Credential' \
  --vault '00-personal/01-chezmoi' \
  --title 'api-key/github.com/vitor@epoch-chrono.com/chezmoi-bootstrap' \
  credential="$GITHUB_API_TOKEN"

# Daqui em diante, pra próximos runs:
set -gx GITHUB_API_TOKEN (op item get '42o44tr7k2rxvmb2a44ee24xcy' \
  --vault 'niarnlvrteesurkbocpta7it4e' \
  --fields credential --reveal)
```

#### Fallback (defensive)

`dot_config/mise/config.toml.tmpl` configura `[settings.github]
credential_command = "op item get ..."`. Cobre runs **interativos
fora do bootstrap** — quando o user roda `mise install nova-tool`
em terminal e esqueceu de exportar `GITHUB_API_TOKEN`, mise tenta
`op` antes de cair pra anônimo.

Bootstrap NÃO depende desse fallback — depende da env var, validada
no início.


### Roles implementadas

| Role | Versão funcional | Cobertura |
|---|---|---|
| `hello` | Sim | Marker file, sanity check |
| `macos-base` | Sim | general, appearance (Purple), dock (48/90, hot corners off), trackpad, sharing (scutil+hostname), firewall (socketfilterfw), finder, keyboard |
| `homebrew` | Sim | 6 fases: pré-check brew → mas-cli pre-flight → MAS cleanup → brew bundle → MAS install → MAS upgrade_all |
| `chezmoi` | Sim | 5 fases: pré-check binary → init source → update (pull+apply) → mise trust → mise install. `when: Darwin` only. |
| `shell` | Sim | 4 fases: pré-check fish → /etc/shells → dscl change UserShell → validar. Última do playbook. macOS only. |


### Chezmoi source root

O próprio repo é a source do chezmoi (paths `dot_*`, `executable_*`, etc. na raiz).
Materializa via `chezmoi apply`:

| Path no repo | Path em $HOME |
|---|---|
| `dot_config/mise/config.toml.tmpl` | `~/.config/mise/config.toml` (com email + context hardcoded) |
| `dot_local/bin/executable_repo-sync` | `~/.local/bin/repo-sync` (executable preservado) |
| `.chezmoi.yaml.tmpl` | Config do chezmoi (renderizado em runtime, não materializado) |
| `.chezmoiignore` | Lista de exclusões (ansible/, bin/, docs/, README.md, etc.) |


### Utility scripts

| Script | Tipo | Função |
|---|---|---|
| `bin/repo-sync` | fish | Drift detector read-only entre estado real e repo. Cobre brew (taps+formulas+casks via `brew bundle dump`) e MAS (via `mas list` vs `mas_apps_to_install`). Stub pra mise até chezmoi entrar. Exit 0 sync, 1 drift, 2 erro de pré-condição. |


### Inventário Brewfile

- 4 taps (hudochenkov/sshpass, fwdcloudsec/granted, cloudquery/tap, turbot/tap)
- 71 brew formulas
- 54 casks ativos + 1 comentado (maccleaner-pro, ver TODOs)
- MAS apps NÃO ficam no Brewfile — movidos pra `homebrew/defaults/main.yml`
  (`brew bundle` chama mas-cli em contexto SSH non-interactive e falha)


### MAS (Mac App Store)

Gerenciado via `community.general.mas` em vez de brew bundle:

- `mas_apps_to_remove`: 5 Apple defaults (GarageBand, iMovie, Keynote, Numbers, Pages)
- `mas_apps_to_install`: 16 apps (15 Safari extensions + iStatistica Pro)
- `upgrade_all: true` após install (modelo "update sempre" pra MAS)
- Pré-req: Apple ID logada na MAS via GUI antes do bootstrap


### Convenções de qualidade

- Pre-commit configurado (gitleaks, shellcheck, yaml/markdown lint)
- Commits Conventional Commits, sem emojis, em pt-BR
- SemVer no header do `site.yml` com changelog inline
- `TARGET_HOSTNAME` obrigatória (cross-platform neutral)


## Próximas fatias (curto prazo)

Ordem proposta. Cada uma é independente e pode ser pausada/retomada.


### 1. Tools adicionais no `dot_config/mise/config.toml.tmpl`

**O quê.** O config atual tem só os 3 core languages (python@3.13.11, node@lts,
go@latest). Adicionar tools restantes conforme o user definir, **ordenadas por
dependência de backend** (core primeiro, depois backends derivados).

**Candidatos identificados em conversas anteriores.**

- CLI dev: `k9s`, `popeye`, `kubectl`, `helm`, `kafkactl`, `granted`
- Cross-language: `pre-commit`, `gitleaks`, `shellcheck` (já no repo `mise.toml`,
  considerar mover pro user-level)

Cada tool requer decidir o **backend mise** apropriado (core/ubi/cargo/go-install/pipx).


### 2. Primeiros dotfiles reais (fish, helix, git)

**O quê.** Migrar configs de uso diário do user pro chezmoi. Cada um em fatia
separada pra revisar mudanças com calma.

**Ordem proposta.**

1. `dot_config/fish/config.fish.tmpl` + `dot_config/fish/conf.d/` (PATH com GNU
   tools, mise activate, abbreviations, etc.)
2. `dot_config/helix/config.toml.tmpl` (theme, keymaps)
3. `dot_gitconfig.tmpl` (email via 1Password, primeiro caso de uso de `op://`)


### 3. 1Password integration

**Quando.** No momento que aparecer o primeiro template com secret. Provável
que seja no `dot_gitconfig.tmpl` (signing key, email).

**Approach inicial:** Opção C (`op://<vault>/<item>/<field>` direto no template).
Migrar pra Opção B (`.chezmoidata/secrets.yaml` com aliases) quando o número de
referências ou frequência de renomeação justificar.


## Roadmap Nix (médio/longo prazo)

Direção estratégica: convergir o stack pra Nix nas próximas iterações maiores.
Não-blocker — incrementos progressivos, cada fase pagando seu próprio custo.


### Por que Nix

- **Declarativo de verdade.** Estado da máquina inteira é uma função pura do
  manifesto. Ansible aproxima isso; Nix é exato.
- **Cross-platform real.** Mesmo idioma (Nix expressions) pra Linux e macOS.
- **Reprodutibilidade absoluta.** Não é "tente reproduzir"; é "se compilou aqui,
  compila lá idêntico".
- **Per-project dev shells.** `direnv` + `flake.nix` por projeto. Sem precisar
  poluir o sistema global com toolchains de projetos one-off.


### Ferramentas Nix em cada camada

| Camada | Tool | Substituiria |
|---|---|---|
| Linux (host) | **NixOS** | Ubuntu/Debian (atualmente apt) |
| macOS (host) | **nix-darwin** | Parte do `macos-base` role (defaults macOS, services) |
| User env (ambos) | **home-manager** | chezmoi (parcial ou total) |
| Per-project | **flake.nix + direnv** | nada (feature adicional) |


### Fases de adoção

#### Fase 1: Nix package manager presente, sem mudança de stack

- Adicionar `brew "nix"` ao Brewfile OU Determinate Systems installer (mais robusto)
- `direnv` já planejado no mise — configurar `use flake` hook
- Cada projeto pode declarar `flake.nix` opcional
- **Stack atual continua intocado**

#### Fase 2: home-manager opcional pra dotfiles selecionados

- Subset de dotfiles migra pra home-manager (Nix expressions)
- chezmoi continua gerenciando o resto
- Coexistência pacífica — home-manager não toca em arquivos fora do que declara

#### Fase 3: nix-darwin substitui partes do Ansible

- `macos-base` defaults migram pra nix-darwin (`defaults_write` → `darwin.defaults`)
- Brew permanece (nix-darwin tem módulo `homebrew` built-in)
- Sharing, firewall, hostname podem migrar
- Role Ansible vira progressivamente menor

#### Fase 4: Linux bootstrap = NixOS pure

- Quando precisarmos do primeiro host Linux, é NixOS
- `configuration.nix` declarando hardware + sistema + serviços
- home-manager pro user env
- Não tem role Ansible Linux equivalente — Nix faz tudo


### Coisas a registrar pra quando começar Fase 1

- Avaliar `brew "nix"` vs Determinate Systems installer
- Configurar `direnv` com `use flake` hook universal
- Documentar workflow per-project: `flake.nix` + `.envrc` com `use flake`


## Convenções de código

### Sintaxe portável em scripts versionados

Scripts em `bin/` (e hooks chezmoi futuros) usam sintaxe portável de coreutils:
compatível com BSD + GNU `awk`, `sed`, `grep`, etc. Não dependem de
`gawk`/`gsed`/etc. especificamente, nem de paths absolutos pra binários.

**Motivação.**

- **Cross-platform.** O mesmo script roda no macOS (com BSD tools nativos ou
  com GNU via brew), no Linux com GNU nativo, e no NixOS futuro. Não importa
  qual versão o PATH resolve.
- **Robustez a mudanças de PATH.** O shell pessoal do user pode prepender GNU
  tools no PATH (recomendado pro uso interativo). Essa config NÃO quebra
  scripts versionados que assumem só features portáveis.
- **Bootstrap-friendly.** Scripts funcionam em contextos com PATH minimal
  (SSH non-interactive, CI, container), onde GNU tools podem não estar
  acessíveis pelo nome curto.

**Exemplo prático.**

```awk
# Portável (BSD + GNU): usa sub destrutivo
/id:.*"[0-9]+"/ {
    s = $0
    sub(/.*id:[[:space:]]*"/, "", s)
    sub(/".*/, "", s)
    print s
}

# Evitar: GNU-only (match com 3 args, captura em array)
match($0, /id:[[:space:]]*"([0-9]+)"/, m) { print m[1] }
```

**Onde GNU tools vão entrar.** Em `dot_config/fish/config.fish` (via chezmoi),
o user prepende `gnubin` dirs ao PATH pra que `awk` invoque `gawk`, `sed`
invoque `gsed`, etc. — comportamento previsível e mais features no terminal
interativo. Mas isso é config pessoal, fora do escopo de scripts versionados.


### Preferência por brew sobre MAS quando disponível

Quando um app MAS é descontinuado pelo vendor (deixa a Mac App Store) e
existe alternativa moderna distribuída via Homebrew, **migrar pra brew**.

**Motivação.**

- **Resiliência a deprecation da Apple.** Vendors saem da MAS por várias razões
  (Apple sandboxing requirements, taxas, modelo de distribuição). Apps via
  brew dependem só do developer manter releases, sem intermediário Apple.
- **Reprodutibilidade.** `mas install <id>` falha se o app foi removido da MAS,
  mesmo que o ID ainda exista. Brew cask aponta pro DMG do upstream — funciona
  enquanto o upstream existir.
- **Idempotência preservada.** Repo continua declarativo; instalável em Mac fresh.

**Caso concreto registrado.**

EasyRes (`id: 688211836`) — descontinuado da MAS pelo developer (~2024).
Macs que já tinham instalado continuam com a v1.1.4 funcional, mas instalação
nova é impossível via `mas install`.

Substituído por:

- `cask "betterdisplay"` — replacement principal, GUI moderno gratuito
- `brew "displayplacer"` — CLI complementar, script-friendly pra automações


## TODOs pontuais (backlog técnico)

Itens isolados que não cabem nas fatias acima.


### Chezmoi (descobertos no primeiro bootstrap end-to-end)

- **Source duplicado**: bootstrap.sh clona em `~/.local/share/dotfiles/` e
  chezmoi clona em `~/.local/share/chezmoi/`. Atualmente resolvido via
  `chezmoi update` (que faz git pull no source dir do chezmoi antes de
  apply). Refactor possível: configurar chezmoi `sourceDir` apontando pro
  bootstrap clone (single source of truth). Trade-off pendente: zero
  acoplamento (atual) vs simplicidade arquitetural.

- **Perm `0755` em `~/.config/`**: `chezmoi apply` setou perm permissiva
  no diretório (`drwxr-xr-x`). Convenção comum pra `~/.config` é `0700`
  ou `0750`. Investigar e configurar via `umask` ou chezmoi attribute.

### Mise (descobertos no primeiro bootstrap end-to-end)

- **Mise shims no PATH do login shell** (importante pra IDEs): IDEs como
  Cursor, Claude Code, VS Code, IntelliJ trabalham melhor com **shims**
  do mise que com `mise activate` (que modifica PATH a cada prompt do
  shell e só roda em shells interativos).

  Spawn de subprocess em GUI apps NÃO herda PATH do shell interativo —
  cursor lança `node`, `python`, `terraform`, etc. e não encontra os
  binários instalados pelo mise. Sintoma típico: extensão da IDE
  reclama de tool ausente mesmo após `mise install`.

  Doc oficial: https://mise.jdx.dev/dev-tools/shims.html#adding-shims-to-path

  Adicionar `~/.local/share/mise/shims` ao PATH em:

    - macOS:
        - Bash:  ~/.bash_profile
        - Zsh:   ~/.zprofile (ou ~/.zshenv pra IDEs spawn de GUI)
        - Fish:  ~/.config/fish/conf.d/00-mise-shims.fish
                 (fish não distingue rc/profile, conf.d roda sempre,
                 prefixo 00- garante ordem)

    - macOS GUI apps (Spotlight/Dock launch, fora do terminal):
        - launchctl setenv PATH ou LaunchAgent plist persistente,
          OU configurar `terminal.integrated.env.osx` per-app
          (Cursor/VS Code suporta).

  Verificar default shell antes de decidir onde inserir:
    dscl . -read /Users/$USER UserShell

  Implementação: criar dotfile fish/config compatível no chezmoi
  (provavelmente `dot_config/fish/conf.d/00-mise-shims.fish`) com:
    set -gx PATH "$HOME/.local/share/mise/shims" $PATH

  Cuidado: shims vs `mise activate` — usar UM ou OUTRO, não ambos.
  Shims são mais lentos por invocação (mise resolve a versão correta
  em cada call) mas funcionam em qualquer contexto. Activate é mais
  rápido mas só funciona em shell interativo.

  Recomendação: shims globais via PATH login + activate adicional
  no shell interativo pra ganhar `mise hook-env` features (env vars
  por projeto, hooks `cd`, etc.).

- **Duplicação `chezmoi` brew vs mise**: chezmoi está no Brewfile
  (`/opt/homebrew/bin/chezmoi`) E no `mise.toml` do repo
  (`~/.local/share/mise/installs/chezmoi/...`). Roles hardcodam o path
  do brew binary, então sem conflito imediato — mas duas fontes da verdade
  pra mesma ferramenta. **Decisão pendente** após avaliar uso real:

  **Análise de duplicações brew vs mise (após v0.26.0):**
  Comparação automática: dos 78 brews + 96 tools no mise registry direto,
  apenas **`chezmoi`** aparece em ambos. Nenhum outro duplicado significativo.

  **Recomendação**: manter chezmoi no brew (necessário pra bootstrap antes
  do mise existir) e **remover do mise**. Comentar no mise config como
  "gerenciado via brew — não duplicar pra evitar PATH conflict". Upgrade
  manual via `brew upgrade chezmoi` quando necessário.

- **Brew "latest" vs mise reporta outdated**: brews sem versão pinada
  (ex.: `brew "fd"`) instalam a versão atual do **brew-core**, que tem
  delay de dias/semanas vs upstream (releases brew-core são revisadas
  por maintainers antes de merge). Se mesma tool estiver no mise via
  backend `aqua:`/`ubi:`/`go:`, mise pega direto do upstream — pode
  reportar "versão mais nova disponível" que o brew.

  **Não é conflito**: como NÃO há duplicação significativa (só chezmoi —
  resolver acima), cada tool tem fonte única. Mise reportar "outdated"
  pra tools do brew é só **informativo** — ele compara seu próprio
  registry com o que ele acha instalado, sem distinguir gerenciador.

  Pra silenciar warnings de mise sobre tools brew-managed: nada a fazer,
  são WARN não ERROR. Pra atualizar brews ativamente: o playbook já
  roda `brew bundle` (sem `--no-upgrade`) em cada bootstrap, mantendo
  formulas atualizadas. Casks self-updating cobertos pela task
  `brew upgrade --cask --greedy` (que já é UNIÃO de
  `--greedy-auto-updates` + `--greedy-latest`).

- **fnox como alternativa ao op-creds**: jdx (autor do mise) lançou
  https://github.com/jdx/fnox — manager de secrets unificado.
  Suporta múltiplos backends (1Password, AWS Secrets Manager, age, etc.)
  com sintaxe declarativa similar ao mise. Avaliar como substituto/
  complemento ao `op-creds` skill pessoal:

  **Pros potenciais:**
  - Sintaxe declarativa idiomática ao ecossistema mise/jdx
  - Cache local opcional (offline workflow)
  - Multi-backend (não amarra a 1Password)
  - Integração nativa com mise (env vars resolvidos no hook-env)

  **Cons / cautelas:**
  - Projeto novo, API pode mudar
  - Vendor lock-in moderado (ecossistema jdx)
  - op-creds skill atual já está estável e testado

  fnox está adicionado ao mise config (`fnox = "1.23.1"`) — comparar
  workflow com op-creds e decidir.

- **`mise install` herda `./mise.toml` do CWD**: task Ansible roda no
  diretório `~/.local/share/dotfiles/` (CWD do `connection: local`),
  então mise vê tanto o config user-level (`~/.config/mise/config.toml`)
  quanto o repo-level (`./mise.toml`). Resultado atual: ambos os configs
  são instalados (7 tools). Pode ser feature (user ganha dev tools do
  repo de graça) ou bug (comportamento implícito). Decidir: `chdir`
  explícito na task ou documentar como intencional.

- **`mise WARN gpg not found`**: mise procura `gpg` pra verificar
  attestations de releases. `gnupg` está no Brewfile (e instala como
  `/opt/homebrew/bin/gpg`), mas mise não encontra no PATH durante
  Ansible run. Investigar: PATH na task ou adicionar `gpg` explícito.

### Brewfile

- **`maccleaner-pro` desabilitado** (cask comentado): checksum mismatch upstream
  (Nektony serve binary diferente do que o cask declara). Re-habilitar quando
  cask atualizar no Homebrew core.

- **Validar periodicamente** se `tunnelblick@beta` ainda é necessário ou se a
  versão stable cobre o que Apoia.se usa.


### MAS

- **`mas list` em primeira execução em Mac fresh** pode retornar vazio se
  Spotlight ainda não indexou. Diagnóstico atual é manual; considerar `mdimport
  /Applications` defensivamente no role se virar dor.


### Ansible

- **Decidir versão Ansible target.** Atualmente usa whatever venv pinou no
  bootstrap. Considerar fixar minor version no `requirements.txt` futuro.

- **Tags por role pra runs cirúrgicos.** Permitiria `ansible-playbook site.yml
  --tags homebrew` sem rodar `macos-base`. Útil pra debug.


### Chezmoi (quando entrar)

- **Hook `mise install` após config.toml mudar**: `run_onchange_after_50-mise-install.sh.tmpl`
  detecta mudança no template, roda `mise install` automaticamente. Padrão
  recomendado pelo chezmoi pros casos onde um manifesto declara estado
  externo à pasta source.

- **Padrão 1Password naming** já registrado em preferências pessoais:
  `vault: 00-personal/01-chezmoi`, type `Api Credentials`, title
  `<tipo>/<domain>/<user>/<onde-usa>`, campo `credential`. Aplicar
  consistentemente.


### Mac antigo (migração)

- **Limpeza só pós-migração.** Mac antigo é production atualmente — zero
  comandos destrutivos enquanto não virar máquina de teste.

- **Tap cleanup** quando virar teste: `brew untap homebrew/bundle && brew untap
  homebrew/services` (ambos são built-in no Homebrew 4.5+, não precisam mais).


### Roadmap Nix preparatório

- **Backup do Brewfile inventory** antes de qualquer experimento Nix —
  source-of-truth atual.

- **Aprender Nix expressions** antes da Fase 2. Não pular pra home-manager
  copiando exemplos sem entender.


## Como atualizar este doc

Quando uma fatia for concluída, mover da seção "próximas fatias" pra "estado
atual". Quando um TODO for resolvido, remover. Quando uma decisão arquitetural
nova for tomada, registrar inline com data e contexto.

Commit convention pra mudanças aqui: `docs(roadmap): <mudança>`.
