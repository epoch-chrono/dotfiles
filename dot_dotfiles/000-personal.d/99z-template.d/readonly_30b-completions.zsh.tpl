#!/usr/bin/env zsh
# ────────────────────────────────────────────────────────────────────────
# 30b-completions.zsh.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.zsh' não casa com '*.zsh.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  personal  (configurações pessoais (não vinculadas a cliente))
#   Stage:   30  (completions)
#   Shell:   zsh
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 30b-completions.zsh.tpl ../<scope-dir>/30b-completions.zsh
#   3. chmod 0644 no destino pra poder editar.
#   4. Substitua o conteúdo do bloco "Body" pelos comandos reais.
#
# NOTA: stage `functions` (que existia em v1.0) foi REMOVIDO. Functions de
# qualquer shell vivem em ~/.config/{fish,zsh,bash}/functions/<name>.zsh.
# Ver docs/TAXONOMY.md → 'Functions: exceção à regra ~/.dotfiles/'.
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


# ── Exemplos comentados (zsh, personal) ────────────────────────────────────
# # [[ -f "$HOME/.iterm2_shell_integration.zsh" ]] && \
# #     source "$HOME/.iterm2_shell_integration.zsh"
# #
# # [[ -f "$HOME/.config/op/plugins.sh" ]] && \
# #     source "$HOME/.config/op/plugins.sh"


# ── Body — adicione comandos abaixo ────────────────────────────────────────

