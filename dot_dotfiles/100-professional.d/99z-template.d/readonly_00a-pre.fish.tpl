#!/usr/bin/env fish
# ────────────────────────────────────────────────────────────────────────
# 00a-pre.fish.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.fish' não casa com '*.fish.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  professional  (configurações de cliente/profissional (escopo por entidade))
#   Stage:   00  (pre)
#   Shell:   fish
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 00a-pre.fish.tpl ../<scope-dir>/00a-pre.fish
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


# ── Boas práticas (fish) ───────────────────────────────────────────────────
# Nada que dependa de PATH/binários — estes ainda não foram
# ordenados pelos stages posteriores.
# Idempotente: `set -gx VAR value` é seguro repetir.
# Use `set -q VAR; or set -gx VAR value` para só setar se ausente.


# ── Exemplos comentados (fish, professional) ───────────────────────────────
# # set -gx <CLIENT>_HOME $HOME/Git/100-professional.d/<NN>-<slug>.d
# # set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME $HOME/.config


# ── Body — adicione comandos abaixo ────────────────────────────────────────

