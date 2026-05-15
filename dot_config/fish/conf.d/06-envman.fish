# ──────────────────────────────────────────────────────────────────────────
# ~/.config/fish/conf.d/06-envman.fish
# Managed by chezmoi: github.com/epoch-chrono/dotfiles
# ──────────────────────────────────────────────────────────────────────────
# envman (https://github.com/EnvManager/envman) — env vars por projeto.
# Carrega autoenv-like behavior por dir (.envrc-style mas via comando).
#
# Instalado via mise/brew. Gera ~/.config/envman/load.fish quando ativado.
# Source guardado por `test -s` (size > 0) pra evitar erro caso o arquivo
# exista vazio em estado intermediário.

test -s $HOME/.config/envman/load.fish
and source $HOME/.config/envman/load.fish
