#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────────
# 00c-pre.bash.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.bash' não casa com '*.bash.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  professional  (configurações de cliente/profissional (escopo por entidade))
#   Stage:   00  (pre)
#   Shell:   bash
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 00c-pre.bash.tpl ../<scope-dir>/00c-pre.bash
#   3. chmod 0644 no destino pra poder editar.
#   4. Substitua o conteúdo do bloco "Body" pelos comandos reais.
#
# Edições neste arquivo serão sobrescritas pelo chezmoi no próximo apply
# (esta versão é a canônica no repo, não no Mac).
# ────────────────────────────────────────────────────────────────────────


# ── Propósito ──────────────────────────────────────────────────────────────
# Bootstrap muito early — antes de qualquer outra coisa do lifecycle.
# Roda primeiro em cada fragment dir; estágios posteriores assumem o
# que aqui é setado.


# ── Conteúdo típico ────────────────────────────────────────────────────────
# Coisas que devem existir ANTES de env vars, PATH, functions:
#   - umask
#   - XDG_* paths se ainda não setados pelo OS
#   - locale (LANG, LC_*) se relevante
#   - flags de comportamento que afetam load dos próximos stages


# ── Boas práticas (bash) ───────────────────────────────────────────────────
# Nada que dependa de PATH/binários — estes ainda não foram
# ordenados pelos stages posteriores.
# Idempotente: `export VAR=value` é seguro repetir.
# NUNCA usar `set -e` aqui (é fragment sourceado — quebra o shell).


# ── Exemplos comentados (bash, professional) ───────────────────────────────
# # export <CLIENT>_HOME="$HOME/Git/100-professional.d/<NN>-<slug>.d"


# ── Body — adicione comandos abaixo ────────────────────────────────────────

