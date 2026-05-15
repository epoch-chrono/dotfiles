#!/usr/bin/env zsh
# ────────────────────────────────────────────────────────────────────────
# 30b-aliases.zsh.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.zsh' não casa com '*.zsh.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  professional  (configurações de cliente/profissional (escopo por entidade))
#   Stage:   30  (aliases)
#   Shell:   zsh
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 30b-aliases.zsh.tpl ../<scope-dir>/30b-aliases.zsh
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


# ── Boas práticas (zsh) ────────────────────────────────────────────────────
# `alias name=value`. Para abbreviations zsh-like, considere
# plugins como `zsh-abbr` (não vem nativo).
# Aliases não funcionam dentro de scripts (apenas interactive).


# ── Exemplos comentados (zsh, professional) ────────────────────────────────
# # alias aws-<client>='aws --profile <client>'
# # alias k-<client>='kubectl --context <client>-prod'


# ── Body — adicione comandos abaixo ────────────────────────────────────────

