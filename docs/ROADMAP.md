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


### Roles implementadas

| Role | Versão funcional | Cobertura |
|---|---|---|
| `hello` | Sim | Marker file, sanity check |
| `macos-base` | Sim | general, appearance (Purple), dock (48/90, hot corners off), trackpad, sharing (scutil+hostname), firewall (socketfilterfw), finder, keyboard |
| `homebrew` | Sim | 6 fases: pré-check brew → mas-cli pre-flight → MAS cleanup → brew bundle → MAS install → MAS upgrade_all |
| `chezmoi` | Sim | 5 fases: pré-check binary → init source → apply → mise trust → mise install. `when: Darwin` only (Linux NixOS futuro). |


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
