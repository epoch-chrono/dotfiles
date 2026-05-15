#!/usr/bin/env zsh
# ────────────────────────────────────────────────────────────────────────
# 50b-post.zsh.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.zsh' não casa com '*.zsh.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  professional  (configurações de cliente/profissional (escopo por entidade))
#   Stage:   50  (post)
#   Shell:   zsh
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 50b-post.zsh.tpl ../<scope-dir>/50b-post.zsh
#   3. chmod 0644 no destino pra poder editar.
#   4. Substitua o conteúdo do bloco "Body" pelos comandos reais.
#
# Edições neste arquivo serão sobrescritas pelo chezmoi no próximo apply
# (esta versão é a canônica no repo, não no Mac).
# ────────────────────────────────────────────────────────────────────────


# ── Propósito ──────────────────────────────────────────────────────────────
# Cleanups, dedup, late overrides.
# Roda DEPOIS de todos os outros stages — última chance de ajustar.


# ── Conteúdo típico ────────────────────────────────────────────────────────
# PATH dedupe, remoção de vars temporárias, overrides finais que
# precisam sobrescrever algo setado por algum stage anterior ou plugin.


# ── Boas práticas (zsh) ────────────────────────────────────────────────────
# Cuidado com side effects.
# `typeset -U path` já dedupe automaticamente — se usado em stage 10,
# este stage pode ficar vazio no que tange PATH.
# `unset VAR` remove a var.


# ── Exemplos comentados (zsh, professional) ────────────────────────────────
# # export STARSHIP_CONFIG="$HOME/.config/starship-<client>.toml"


# ── Body — adicione comandos abaixo ────────────────────────────────────────

