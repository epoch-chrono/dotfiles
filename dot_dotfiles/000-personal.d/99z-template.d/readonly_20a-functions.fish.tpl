#!/usr/bin/env fish
# ────────────────────────────────────────────────────────────────────────
# 20a-functions.fish.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.fish' não casa com '*.fish.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  personal  (configurações pessoais (não vinculadas a cliente))
#   Stage:   20  (functions)
#   Shell:   fish
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 20a-functions.fish.tpl ../<scope-dir>/20a-functions.fish
#   3. chmod 0644 no destino pra poder editar.
#   4. Substitua o conteúdo do bloco "Body" pelos comandos reais.
#
# Edições neste arquivo serão sobrescritas pelo chezmoi no próximo apply
# (esta versão é a canônica no repo, não no Mac).
# ────────────────────────────────────────────────────────────────────────


# ── Propósito ──────────────────────────────────────────────────────────────
# Funções shell custom.
# Funções pequenas/médias que ganham em estar definidas eagerly.


# ── Conteúdo típico ────────────────────────────────────────────────────────
# Functions de uso frequente, helpers locais ao usuário, wrappers de
# tools que recebem args complexos.


# ── Boas práticas (fish) ───────────────────────────────────────────────────
# PREFIRA `~/.config/fish/functions/<name>.fish` (auto-load lazy).
# Use este arquivo só para functions que devem ser definidas
# eagerly (usadas em prompt, em outros fragments deste lifecycle).
# Sempre declare `--description` (vira help no `functions`).
# Locals com `set -l`. Não vaze namespace.


# ── Exemplos comentados (fish, personal) ───────────────────────────────────
# # function gst --description 'git status short branch'
# #     git status -sb $argv
# # end
# #
# # function mkcd --description 'mkdir -p + cd'
# #     mkdir -p $argv[1]; and cd $argv[1]
# # end


# ── Body — adicione comandos abaixo ────────────────────────────────────────

