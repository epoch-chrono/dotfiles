# ──────────────────────────────────────────────────────────────────────────
# ~/.config/fish/conf.d/08-antigravity.fish
# Managed by chezmoi: github.com/epoch-chrono/dotfiles
# ──────────────────────────────────────────────────────────────────────────
# Antigravity (https://antigravity.google) — Google AI-first IDE.
# Adiciona binários CLI ao PATH se instalado.
#
# Instalado pelo próprio app em ~/.antigravity/antigravity/bin. O installer
# costuma adicionar duas linhas idênticas ao config.fish — esta versão
# centralizada substitui ambas e fica inerte se o user desinstalar (test
# -d falha → fish_add_path não roda).

test -d $HOME/.antigravity/antigravity/bin
and fish_add_path $HOME/.antigravity/antigravity/bin
