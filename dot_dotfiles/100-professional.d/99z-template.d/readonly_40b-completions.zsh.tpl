#!/usr/bin/env zsh
# ────────────────────────────────────────────────────────────────────────
# 40b-completions.zsh.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.zsh' não casa com '*.zsh.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  professional  (configurações de cliente/profissional (escopo por entidade))
#   Stage:   40  (completions)
#   Shell:   zsh
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 40b-completions.zsh.tpl ../<scope-dir>/40b-completions.zsh
#   3. chmod 0644 no destino pra poder editar.
#   4. Substitua o conteúdo do bloco "Body" pelos comandos reais.
#
# Edições neste arquivo serão sobrescritas pelo chezmoi no próximo apply
# (esta versão é a canônica no repo, não no Mac).
# ────────────────────────────────────────────────────────────────────────


# ── Propósito ──────────────────────────────────────────────────────────────
# Source de completions externas e integrations de tools.
# Plugins, shell integrations (iTerm2, Starship customs, op plugins).


# ── Conteúdo típico ────────────────────────────────────────────────────────
# Source de arquivos de completion gerados por outras tools, init
# scripts de plugins, integrations de terceiros.


# ── Boas práticas (zsh) ────────────────────────────────────────────────────
# Use `[[ -f <file> ]] && source <file>` (guard).
# Completions zsh nativas vão em `$fpath` + `autoload -U compinit`.
# Aqui pra plugins externos, op plugin init, etc.


# ── Exemplos comentados (zsh, professional) ────────────────────────────────
# # [[ -f "$HOME/.config/<client>/completions.zsh" ]] && \
# #     source "$HOME/.config/<client>/completions.zsh"


# ── Body — adicione comandos abaixo ────────────────────────────────────────

