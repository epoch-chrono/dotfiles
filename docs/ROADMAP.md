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


### Utility scripts

| Script | Tipo | Função |
|---|---|---|
| `bin/repo-sync` | fish | Drift detector read-only entre estado real e repo. Cobre brew (taps+formulas+casks via `brew bundle dump`) e MAS (via `mas list` vs `mas_apps_to_install`). Stub pra mise até chezmoi entrar. Exit 0 sync, 1 drift, 2 erro de pré-condição. |


### Inventário Brewfile

- 4 taps (hudochenkov/sshpass, fwdcloudsec/granted, cloudquery/tap, turbot/tap)
- 70 brew formulas
- 53 casks ativos + 1 comentado (maccleaner-pro, ver TODOs)
- MAS apps NÃO ficam no Brewfile — movidos pra `homebrew/defaults/main.yml`
  (`brew bundle` chama mas-cli em contexto SSH non-interactive e falha)


### MAS (Mac App Store)

Gerenciado via `community.general.mas` em vez de brew bundle:

- `mas_apps_to_remove`: 5 Apple defaults (GarageBand, iMovie, Keynote, Numbers, Pages)
- `mas_apps_to_install`: 17 apps (15 Safari extensions + EasyRes + iStatistica Pro)
- `upgrade_all: true` após install (modelo "update sempre" pra MAS)
- Pré-req: Apple ID logada na MAS via GUI antes do bootstrap


### Convenções de qualidade

- Pre-commit configurado (gitleaks, shellcheck, yaml/markdown lint)
- Commits Conventional Commits, sem emojis, em pt-BR
- SemVer no header do `site.yml` com changelog inline
- `TARGET_HOSTNAME` obrigatória (cross-platform neutral)


## Próximas fatias (curto prazo)

Ordem proposta. Cada uma é independente e pode ser pausada/retomada.


### 1. Estrutura `chezmoi/` no repo

**O quê.** Materializar a pasta source do chezmoi com os primeiros dotfiles.

**Conteúdo inicial proposto.**

```
chezmoi/
├── .chezmoi.toml.tmpl                    # config do chezmoi (modo 1Password, vars)
├── .chezmoidata/
│   └── system.yaml                       # vars compartilhadas (hostname, profile)
├── dot_config/
│   └── mise/
│       └── config.toml.tmpl              # python@3.13.11, node@lts, go@latest, tools
├── dot_local/
│   └── bin/
│       └── executable_repo-sync          # script `bin/repo-sync`, migrado
└── run_onchange_after_50-mise-install.sh.tmpl  # hook: mise install quando config muda
```

**Decisões a tomar quando chegar a hora.**

- Modo 1Password: começar com Opção C (`op item get` com nomes direto), migrar
  pra Opção B (`.chezmoidata/secrets.yaml` com IDs nomeados) quando justificar
- Estrutura inicial mínima: só `mise` + `repo-sync`. Fish/Helix/Git em fatias
  separadas pra revisar com calma


### 2. Role `chezmoi-bootstrap` no Ansible

**O quê.** Última peça do bootstrap: deixar o chezmoi inicializado e aplicado.

**Tasks (~30 linhas YAML).**

1. `stat ~/.local/share/chezmoi/` — verifica se já existe
2. `chezmoi init https://github.com/epoch-chrono/dotfiles.git` — se primeira vez
3. `chezmoi apply` — sempre (idempotente)

**Ordem.** Última no `site.yml`, depois de `homebrew` (chezmoi precisa do binary
instalado, que vem do brew bundle).


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
