# Taxonomia v1 — diretórios e fragments

Este documento é o **espelho sanitizado** da página interna no Notion
"Definir taxonomia de diretórios (personal vs client/`<slug>`)". A página
Notion permanece a *source of truth*; este `.md` no repo serve como
referência rápida e versionada para colaboradores futuros.

**Sanitização**: nomes reais de empresas/clientes foram substituídos por
placeholders (`cliente-foo`, `cliente-bar`, …). A sequência real e a
ordem cronológica vivem apenas em docs internos.

---

## Diagnóstico (o problema)

Antes da v1, quatro padrões conflitantes conviviam nas raízes de organização:

| Local | Pessoal | Profissional | Sufixo |
|---|---|---|---|
| `~/Git/` | `00-private.d` | `01-customer.d` | `.d` |
| `~/Git/OpenCodeSpace/` | `personal` | `professional` | (nenhum) |
| `~/.ssh/assh/` | `00-personal.d` | `01-customer.d` | `.d` |
| `~/.dotfiles/` | `00-private.d` | `01-customer.d` | `.d` |

Ambiguidade entre `private`/`personal`, `customer`/`professional`, e
inconsistência de prefixos digitais. A v1 unifica.

---

## Taxonomia Unificada v1

### Estrutura raiz `~/Git/`

````text
~/Git/
├── 000-personal.d/
│   ├── <projeto-pessoal-foo>/
│   ├── <projeto-pessoal-bar>/
│   ├── dotfiles/
│   └── ...
├── 100-professional.d/
│   ├── 00-epoch.d/                      ← âncora (empresa própria)
│   │   ├── <repo-foo>/
│   │   └── <repo-bar>/
│   ├── 01-cliente-foo.d/                ← clientes ativos
│   │   ├── github/
│   │   └── bitbucket/
│   ├── 02-cliente-bar.d/
│   └── ...
├── 900-archive.d/
│   ├── 11-cliente-baz.arch/             ← clientes inativos (prefixo preservado)
│   ├── 12-projeto-foo.arch/
│   └── ...
└── 999-sandbox.d/
    └── ...
````

### Vocabulário

| Prefixo | Nome | Descrição |
|---|---|---|
| `000` | `000-personal.d` | Projetos pessoais, não vinculados a cliente |
| `100` | `100-professional.d` | Guarda-chuva profissional |
| `100/00` | `00-epoch.d` | Âncora — empresa própria, sempre existe |
| `100/01+` | `01-<slug>.d` | Clientes ativos (2-digit sequencial cronológico) |
| `900` | `900-archive.d` | Projetos/clientes inativos |
| `999` | `999-sandbox.d` | Experimentos, POCs, temporários |

### Regras de prefixo

- **Nível raiz** (`~/Git/`): 3-digit com ranges semânticos (000, 100, 900, 999)
- **Dentro de `100-professional.d/`**: 2-digit sequencial (00, 01, 02, …)
- **Sem ambiguidade**: `100` aparece uma vez só (professional); dentro dele prefixos são 2-digit

### Sufixos `.d` e `.arch`

`.d` é marcador de "diretório organizacional / fragmentos":

- **Aplicar em**: dirs de escopo (`000-personal.d`, `01-cliente-foo.d`), config fragments (`conf.d`, `assh.d`)
- **Não aplicar em**: dirs internos de projetos, dirs impostos por ferramentas (`.config/`, `.cursor/`), subdivisões por host (`github/`, `bitbucket/`)

`.arch` é marcador de "diretório arquivado" — substitui o `.d` quando o item move pra `900-archive.d/`:

- **Convenção**: `100-professional.d/11-swap.d/` → `900-archive.d/11-swap.arch/`
- **Prefixo numérico preservado** na migração (mantém proveniência histórica)
- **Re-ativação** (volta pra ativo): mantém o número original (`11-swap.arch` → `11-swap.d`)
- **Por que `.arch` e não `.d`**: evita confusão visual num glance, e não conflita com `.d` usado por systemd/conf.d

### Regras de naming

| Elemento | Padrão | Exemplo |
|---|---|---|
| Slugs de cliente | `lowercase-ascii` | `cliente-foo`, `cliente-bar` |
| Filenames | `kebab-case` | `cursor-settings.json` |
| Timestamps (filename) | `YYYYMMDD-HHmm` | `20260410-1315-backup.tar.gz` |
| Timestamps (conteúdo) | ISO 8601 + TZ | `2026-04-10T13:15:00-03:00` |
| Scripts de bootstrap | `NNN-descricao.sh` | `000-install-deps.sh` |
| Fish conf.d / fragments | `<NN><L>-<contexto>.<shell>` | `10a-environment.fish` (ver lifecycle abaixo) |

### OpenCodeSpace

**DESCONTINUADO.** Conteúdo migra para `~/Git/` com taxonomia v1.
IDE atual: Cursor desktop/web + `cursor-agent` CLI.

---

## Convenções complementares (não estavam na v1 original)

Esta seção captura padrões aplicados na prática que estendem ou
particularizam a v1.

### Aplicação global da taxonomia

A v1 não é específica do `~/Git/` — a **mesma semântica de prefixos e
sufixos** aplica a qualquer raiz de organização que contenha mistura
de escopo pessoal e profissional:

- `~/Git/` — repositórios de código
- `~/.dotfiles/` — fragments de shell user-controlled
- `~/.ssh/assh/` — entradas de SSH config gerenciadas pelo [advanced-ssh-config](https://github.com/moul/advanced-ssh-config)
- (futuros) `~/Documents/`, `~/Notes/`, etc.

Em todas: `000-personal.d/` + `100-professional.d/` + `900-archive.d/`
no raiz. Conteúdo varia conforme o domínio, **estrutura é a mesma**.

### Estrutura v1 de `~/.dotfiles/`

````text
~/.dotfiles/
├── 000-personal.d/
│   ├── 00a-pre.fish
│   ├── 00b-pre.zsh
│   ├── 00c-pre.bash
│   ├── 10a-environment.fish
│   ├── 10b-environment.zsh
│   ├── 10c-environment.bash
│   ├── 20a-functions.fish
│   ├── 20b-functions.zsh
│   ├── 20c-functions.bash
│   ├── 30a-aliases.fish
│   ├── 40a-completions.fish
│   └── 50a-post.fish
├── 100-professional.d/
│   ├── 00-epoch.d/
│   │   ├── 10a-environment.fish
│   │   └── ...
│   ├── 01-cliente-foo.d/
│   └── 02-cliente-bar.d/
├── 900-archive.d/
│   └── 11-cliente-baz.arch/
└── logs/                          ← bucket operacional, fora do lifecycle
````

`logs/` é exceção semântica — não é fragment, é depósito de output de
operações (brew, mise, pip, etc.). Convive no raiz mas não segue o
padrão `NNN-<scope>.d`.

### Lifecycle pattern dentro de dirs de fragments

Filenames dentro de `<scope>.d/` (ex: `000-personal.d/`, `01-cliente-foo.d/`)
seguem o pattern `<NN><L>-<contexto>.<shell>`:

- **`NN`** — estágio do lifecycle, em saltos de 10
- **`L`** — letra de ordem de carregamento por shell (ver tabela abaixo)
- **`<contexto>`** — kebab-case, descreve o conteúdo
- **`<shell>`** — extensão do shell (`fish`, `zsh`, `bash`)

#### Estágios

| `NN` | Estágio | Conteúdo típico |
|---|---|---|
| `00` | pre | bootstrap muito early, antes de qualquer outra coisa |
| `10` | environment | env vars (`set -gx`), PATH additions |
| `20` | functions | funções shell |
| `30` | aliases | aliases |
| `40` | completions | source de completions, integrations |
| `50` | post | cleanups, dedup, late overrides |

Saltos de 10 abrem espaço pra sub-fragments futuros sem renumerar
(ex: `15a-paths.fish` entre environment-geral e functions).

#### Letras por shell

| `L` | Shell | Por quê esta ordem |
|---|---|---|
| `a` | fish | shell primário — carrega primeiro |
| `b` | zsh | secundário |
| `c` | bash | fallback / scripts portáveis |

A letra controla **ordem alfabética de carregamento** pelos loaders
que usam `find ... | sort`. Sem a letra, sorting natural daria
`bash < fish < zsh` — fish no meio, errado.

#### Exemplos

| Filename | Stage | Shell | Função |
|---|---|---|---|
| `00a-pre.fish` | pre | fish | Bootstrap super-early |
| `10a-environment.fish` | env | fish | `set -gx OLLAMA_HOST ...` |
| `20a-functions.fish` | fn | fish | Functions complexas (não-lazy) |
| `30a-aliases.fish` | alias | fish | `alias k=kubectl` |
| `50a-post.fish` | post | fish | PATH dedupe final |

### `conf.d/` auto-generated vs `~/.dotfiles/` user-controlled

Princípio de separação:

| Bucket | Origem | Versionado? | Exemplos |
|---|---|---|---|
| `~/.config/<tool>/conf.d/` | gerado por instalação de tools (brew vendor, fisher plugins, mise activate, `op plugin init`, etc.) | normalmente **não** | mise auto-activate vendor file, fisher prompt plugins |
| `~/.dotfiles/` | criado/mantido pelo user | **sim** (chezmoi ou similar) | vars, functions, aliases, integrations capturadas |

**Pattern de captura**: quando uma tool (Antigravity, OpenClaw, etc.)
dumpa configuração diretamente em `~/.config/fish/config.fish` durante
o install, mover esse bloco pra `~/.dotfiles/000-personal.d/<stage>.fish`
e deixar `config.fish` o mais limpo possível.

Override de auto-generated é exceção: se uma tool insiste em colocar
algo em `conf.d/` e o user quer mudar (ex: `mise activate` em `--shims`
em vez do auto-activate full), o override mora em `~/.dotfiles/` e tem
prioridade via ordem de load do shell.

### Multi-shell support

Triplo `.bash/.fish/.zsh` no mesmo dir permite usar um único conjunto
de dotfiles em hosts/ambientes que rodam shells diferentes. Loader em
`config.fish` (ou `.bashrc` / `.zshrc`) filtra por extensão:

````fish
for file in (find $HOME/.dotfiles/000-personal.d -type f -iname '*.fish' | sort)
    source "$file"
end
````

````bash
for file in $(find "$HOME/.dotfiles/000-personal.d" -type f -iname '*.bash' | sort); do
    source "$file"
done
````

### Templates (`99z-template.d/`) e sufixo `.tpl`

Cada raiz com `<NN>-<slug>.d/` dirs (`000-personal.d/`, `100-professional.d/`)
tem **um dir de template** chamado `99z-template.d/`:

````text
~/.dotfiles/
├── 000-personal.d/
│   └── 99z-template.d/                     ← reference, não executado
│       ├── 00a-pre.fish.tpl
│       ├── 10a-environment.fish.tpl
│       └── ...
└── 100-professional.d/
    ├── 00-epoch.d/                         ← entidade real (executado)
    │   ├── 00a-pre.fish
    │   └── 10a-environment.fish
    └── 99z-template.d/                     ← reference, não executado
        ├── 00a-pre.fish.tpl
        └── ...
````

Convenções:

- **Prefixo `99z-`**: força sort pro final em listings ASCII (`z` é tarde no alfabeto). Marca visual de "não-funcional, referência".
- **Sufixo `.tpl`** em cada arquivo: impede o loader do shell de sourcear. `find ... -iname '*.fish'` não casa com `*.fish.tpl`. Convenção pessoal — não é convenção chezmoi (chezmoi usa `.tmpl`, com 2 `m`).
- **Permissão 0444 (read-only)** via prefixo chezmoi `readonly_` no source: o arquivo materializa como `readonly_00a-pre.fish.tpl` no repo, mas chega no Mac como `00a-pre.fish.tpl` com `chmod 0444`. Desencoraja edição manual fora do chezmoi.
- **Conteúdo**: zero código funcional. Apenas shebang + header documentado + seções "Propósito" / "Conteúdo típico" / "Boas práticas" / "Exemplos comentados" / "Body vazio".

Pra usar um template ao criar uma nova entidade (ex: novo cliente):

````bash
# Copiar template removendo .tpl no destino
cp ~/.dotfiles/100-professional.d/99z-template.d/00a-pre.fish.tpl \
   ~/.dotfiles/100-professional.d/03-cliente-novo.d/00a-pre.fish
chmod 0644 ~/.dotfiles/100-professional.d/03-cliente-novo.d/00a-pre.fish
# Editar e substituir o body
````

Templates **personal** e **professional** diferem em exemplos (personal usa
`EDITOR=hx`, `OLLAMA_HOST`, etc.; professional usa `AWS_PROFILE`,
`KUBECONFIG`, etc.) mas têm a mesma estrutura de stages.

---

## Source of truth e atualização

- **Source of truth**: página Notion `Definir taxonomia de diretórios (personal vs client/<slug>)` (privada, com nomes reais)
- **Espelho público**: este arquivo, sanitizado
- **Mudanças**: alterar primeiro o Notion, depois sincronizar pra cá
- **Débito técnico relacionado**: ver página Notion "Débito Técnico — Dotfiles / Taxonomia v1" (privada)
