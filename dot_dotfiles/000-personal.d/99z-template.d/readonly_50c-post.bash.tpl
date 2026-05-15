#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────────
# 50c-post.bash.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.bash' não casa com '*.bash.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  personal  (configurações pessoais (não vinculadas a cliente))
#   Stage:   50  (post)
#   Shell:   bash
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 50c-post.bash.tpl ../<scope-dir>/50c-post.bash
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


# ── Boas práticas (bash) ───────────────────────────────────────────────────
# Cuidado com side effects.
# PATH dedupe manual: `PATH=$(echo $PATH | awk -v RS=: ...)`.
# `unset VAR` remove a var.


# ── Exemplos comentados (bash, personal) ───────────────────────────────────
# # # PATH dedupe (first-seen)
# # PATH=$(printf '%s\n' $PATH | tr ':' '\n' | awk '!seen[$0]++' | paste -sd: -)
# # export PATH
# #
# # unset BOOTSTRAP_TMP


# ── Body — adicione comandos abaixo ────────────────────────────────────────

