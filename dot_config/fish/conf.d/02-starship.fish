# ──────────────────────────────────────────────────────────────────────────────
# ~/.config/fish/conf.d/02-starship.fish
# Managed by chezmoi: github.com/epoch-chrono/dotfiles
# ──────────────────────────────────────────────────────────────────────────────
# Starship — cross-shell prompt
# Docs:   https://starship.rs/
# Config: ~/.config/starship.toml (managed via chezmoi)
#
# `starship init fish` retorna um script fish que redefine fish_prompt
# (e fish_right_prompt). Source-amos pra ativar.
#
# Conditional: `status is-interactive` evita overhead em scripts/non-tty.
#
# NOTA: Se Pure prompt (ou outro) está ativo via fisher, starship sobrescreve
#       o fish_prompt — coexistência funcional mas suja. Cleanup opcional:
#         fisher remove pure-fish/pure   # ou outro prompt anterior
#       Sem cleanup, Starship vence o conflito porque foi sourceado depois.

status is-interactive; and starship init fish | source
