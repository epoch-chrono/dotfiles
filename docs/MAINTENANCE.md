# Maintenance — workflow de renomeação/exclusão

Doc focado em **manutenção do source state** do chezmoi pra evitar lixo
acumulando no destination (Mac / Linux do usuário). Complementar a
`docs/TAXONOMY.md`.

## Problema: chezmoi não rastreia deltas

Chezmoi **não** mantém um log de "o que foi removido". Em cada `apply`, ele
compara o source state **atual** com o destination state atual:

- Source state = arquivos no repo (`dot_*`, etc.)
- Destination state = arquivos no `$HOME`

Resultado: se você **renomeia ou remove** um arquivo no source:

| Operação | No source | No destination |
|---|---|---|
| Renomeação | `foo.txt` → `bar.txt` | `bar.txt` ✅ criado; `foo.txt` ❌ **fica órfão** |
| Exclusão | `foo.txt` deletado | `foo.txt` ❌ **fica órfão** |

Sem intervenção manual, esses órfãos se acumulam no Mac ao longo do tempo.
O usuário acaba com configs antigas zumbis (functions duplicadas, scripts
obsoletos, completions stale, etc.).

## Solução: `.chezmoiremove`

Arquivo `.chezmoiremove` no **root do repo** (mesmo nível dos `dot_*`,
NÃO dentro deles) lista paths que `chezmoi apply` deve remover do
destination automaticamente.

### Sintaxe

- Cada linha = um path ou glob pattern
- **Paths são relativos a `$HOME`** (chezmoi expande automaticamente)
- Linhas começando com `#` = comentários (ignoradas)
- Linhas vazias = ignoradas
- Templating Go suportado (`{{ if eq .chezmoi.os "darwin" }}...{{ end }}`)

### Exemplo

````
# Files renomeados em v0.50.4
.config/fish/functions/brew-compile-env.fish
.config/fish/functions/brew-compile-env-off.fish

# Glob também funciona
.dotfiles/000-personal.d/99z-template.d/old-prefix-*.tpl
````

### Comportamento

`chezmoi apply` lê `.chezmoiremove`, expande paths/globs, e:

- ✅ Se path existe no destination → remove
- ✅ Se path NÃO existe → **silenciosamente ignora** (sem erro)
- ⚠️ Removes acontecem MESMO se o arquivo NÃO foi originalmente criado
  pelo chezmoi — cuidado com globs muito amplos

### Gotcha: braces literais em comentários quebram o parser

O arquivo `.chezmoiremove` INTEIRO (incluindo linhas começando com `#`) é
processado como template Go. **Qualquer `{{` `}}` literal é interpretado
pelo parser, mesmo em comentários explicativos**.

Bug acontecido em v0.51.0 → v0.51.1 — minha linha 14 era:

````
#   - Templating Go suportado (`{{ }}`)
````

Resultado: `chezmoi apply` quebrou com erro
`template: .chezmoiremove:14: missing value for command` (o `{{ }}` foi
interpretado como expressão de template vazia, que é inválida).

**Regras pra escrever comentários no `.chezmoiremove`:**

1. **Não usar `{{` ou `}}` literais** em comentários. Substituir por texto
   descritivo: "sintaxe Go template — ver chezmoi docs".
2. Se precisar mostrar braces na renderização, escapar com syntax Go:
   `{{"{{"}}` → renderiza `{{` no output.
3. Discussões longas sobre template syntax vivem AQUI (em
   `docs/MAINTENANCE.md` que NÃO é templated) e podem usar braces
   livremente em code blocks.

Linter futuro (TD): pre-commit hook que faz `grep -P '(?<!")\{\{|}\}(?!")'`
no `.chezmoiremove` e falha o commit se encontrar braces não-escapados em
linhas de comentário.

## Workflow ao renomear/excluir arquivos tracked

Toda vez que rodar `git mv` ou `git rm` em um arquivo gerenciado pelo
chezmoi, **na mesma sessão de trabalho**:

1. Identifique o path **destination antigo** (o que vai virar órfão)
2. Traduza usando a tabela de prefixos abaixo
3. Adicione ao `.chezmoiremove` na seção do commit/versão atual
4. Commit junto com o rename/delete

### Tabela de tradução source → destination

| Source prefix | Destination | Exemplo |
|---|---|---|
| `dot_<x>` | `.<x>` | `dot_config/fish/...` → `.config/fish/...` |
| `readonly_<f>` | `<f>` (sem prefix, mas com chmod 0444) | `readonly_00a-pre.fish.tpl` → `00a-pre.fish.tpl` |
| `private_<f>` | `<f>` (sem prefix, chmod 0600) | `private_dot_ssh/...` → `.ssh/...` |
| `executable_<f>` | `<f>` (chmod +x) | `executable_dot_local/bin/foo` → `.local/bin/foo` |
| `empty_<f>` | `<f>` (file vazio garantido) | raramente usado |
| `symlink_<f>` | symlink criado com nome `<f>` | source contém o target path |

Prefixos podem ser combinados: `private_dot_ssh/private_config` → `.ssh/config` (chmod 0600).

### Exemplos práticos

**Caso 1 — Renomeação simples:**

````bash
# git mv dot_config/fish/functions/brew-compile-env.fish \
#        dot_config/fish/functions/fn-brew-compile-env.fish
````

Path destination antigo: `.config/fish/functions/brew-compile-env.fish`
→ adicionar essa linha ao `.chezmoiremove`.

**Caso 2 — Delete:**

````bash
# git rm dot_dotfiles/100-professional.d/99z-template.d/readonly_20a-functions.fish.tpl
````

Path destination antigo: `.dotfiles/100-professional.d/99z-template.d/20a-functions.fish.tpl`
→ adicionar essa linha ao `.chezmoiremove`.

**Caso 3 — Renumeração em massa:**

Quando renomeação envolve muitos arquivos similares, agrupar em seção
comentada do `.chezmoiremove` e considerar usar glob:

````
# v0.50.3 — renumbered stages
.dotfiles/000-personal.d/99z-template.d/30a-aliases.fish.tpl
.dotfiles/000-personal.d/99z-template.d/30b-aliases.zsh.tpl
.dotfiles/000-personal.d/99z-template.d/30c-aliases.bash.tpl
````

ou com glob (cuidado com false-positives):

````
.dotfiles/000-personal.d/99z-template.d/3?a-aliases.*.tpl
````

Recomendo paths explícitos (não-glob) por segurança.

## Convenção de organização do `.chezmoiremove`

Seções agrupadas por versão/commit, com comentário explicando o motivo:

````
# ── v0.50.4 (2026-05-15): brew-* renamed to fn-brew-* ────────────────
.config/fish/functions/brew-compile-env.fish
...

# ── v0.50.3 (2026-05-15): functions stage removed from templates ─────
.dotfiles/.../20a-functions.fish.tpl
...
````

Facilita futuro cleanup: quando todos os hosts já tiverem aplicado uma
determinada versão, dá pra remover a seção inteira sem ambiguidade.

## Cleanup de entries antigas

Após **todos** os hosts (Mac primário, Dell NixOS, futuro desktop, etc.)
terem aplicado uma versão específica:

- Remover a seção correspondente do `.chezmoiremove`
- Commit + push
- Nenhum efeito funcional (chezmoi ignora paths que não existem)
- Mantém o arquivo enxuto

**Não há urgência** em fazer cleanup — entries antigas custam ~zero
performance e não causam problema. Cleanup é higiene.

## Pendências futuras

### Pre-commit hook (TD)

Pendente: hook em `.pre-commit-config.yaml` que detecta:

- `git diff --cached --diff-filter=R` (renames staged)
- `git diff --cached --diff-filter=D` (deletes staged)

E pra cada um:
1. Traduz source path → destination path (aplicando regras de prefixos)
2. Verifica se a destination path está em `.chezmoiremove`
3. Se ausente → falha o commit com instrução clara

Beneficio: workflow vira zero-discipline. Quando implementado, o erro
humano de esquecer de atualizar `.chezmoiremove` desaparece.

Complexidade estimada: ~80-100 linhas de bash/python pra cobrir todos
os prefixos chezmoi + `.chezmoiignore` exceptions.

## Aplicação no Mac

Quando rodar `chezmoi apply` numa máquina:

````bash
{
  cd ~/.local/share/dotfiles
  git pull --ff-only origin main
  
  # Preview do que vai mudar (incluindo removes):
  chezmoi diff
  
  # Aplicar:
  chezmoi apply
  
  # Verificar que órfãos foram removidos:
  ls ~/.config/fish/functions/brew-compile-*.fish 2>/dev/null && echo "ainda tem órfão" || echo "✓ limpo"
}|pbc
````
