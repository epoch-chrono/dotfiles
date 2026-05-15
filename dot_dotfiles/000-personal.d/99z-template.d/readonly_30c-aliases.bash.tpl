#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────────
# 30c-aliases.bash.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.bash' não casa com '*.bash.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  personal  (configurações pessoais (não vinculadas a cliente))
#   Stage:   30  (aliases)
#   Shell:   bash
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 30c-aliases.bash.tpl ../<scope-dir>/30c-aliases.bash
#   3. chmod 0644 no destino pra poder editar.
#   4. Substitua o conteúdo do bloco "Body" pelos comandos reais.
#
# Edições neste arquivo serão sobrescritas pelo chezmoi no próximo apply
# (esta versão é a canônica no repo, não no Mac).
# ────────────────────────────────────────────────────────────────────────


# ── Propósito ──────────────────────────────────────────────────────────────
# Aliases e abbreviations.
# Substituições curtas pra comandos longos / frequentes.


# ── Conteúdo típico ────────────────────────────────────────────────────────
# Shortcuts de comandos frequentes: git, kubectl, terraform, etc.


# ── Boas práticas (bash) ───────────────────────────────────────────────────
# `alias name=value`. Não funcionam dentro de scripts (apenas
# interactive). Para scripts, use functions.
# Aliases não recebem args como functions; pra args complexos,
# promover pra stage 20 (functions).


# ── Exemplos comentados (bash, personal) ───────────────────────────────────
# # alias g='git'
# # alias k='kubectl'
# # alias tf='terraform'
# # alias ll='ls -lah'


# ── Body — adicione comandos abaixo ────────────────────────────────────────

