#!/usr/bin/env fish
# ────────────────────────────────────────────────────────────────────────
# 20a-aliases.fish.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.fish' não casa com '*.fish.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  personal  (configurações pessoais (não vinculadas a cliente))
#   Stage:   20  (aliases)
#   Shell:   fish
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 20a-aliases.fish.tpl ../<scope-dir>/20a-aliases.fish
#   3. chmod 0644 no destino pra poder editar.
#   4. Substitua o conteúdo do bloco "Body" pelos comandos reais.
#
# NOTA: stage `functions` (que existia em v1.0) foi REMOVIDO. Functions de
# qualquer shell vivem em ~/.config/{fish,zsh,bash}/functions/<name>.fish.
# Ver docs/TAXONOMY.md → 'Functions: exceção à regra ~/.dotfiles/'.
# ────────────────────────────────────────────────────────────────────────


# ── Propósito ──────────────────────────────────────────────────────────────
# Aliases e abbreviations.
# Substituições curtas pra comandos longos / frequentes.


# ── Conteúdo típico ────────────────────────────────────────────────────────
# Shortcuts de comandos frequentes: git, kubectl, terraform, etc.


# ── Boas práticas (fish) ───────────────────────────────────────────────────
# PREFIRA `abbr -a` sobre `alias`. Abbreviations expandem no
# command-line (UX melhor: você vê o comando completo antes de
# rodar, e elas funcionam dentro de aspas/scripts).
# `alias` em Fish é syntactic sugar pra function — não tem ganho.
# `abbr --query` lista, `abbr --erase <name>` remove.


# ── Exemplos comentados (fish, personal) ───────────────────────────────────
# # abbr -a g git
# # abbr -a k kubectl
# # abbr -a tf terraform
# # abbr -a ll 'eza -lah --icons'
# # abbr -a cat bat
# # abbr -a find fd
# # abbr -a grep rg


# ── Body — adicione comandos abaixo ────────────────────────────────────────

