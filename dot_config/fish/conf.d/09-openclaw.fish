# ──────────────────────────────────────────────────────────────────────────
# ~/.config/fish/conf.d/09-openclaw.fish
# Managed by chezmoi: github.com/epoch-chrono/dotfiles
# ──────────────────────────────────────────────────────────────────────────
# OpenClaw — completions Fish.
# Instalado pelo próprio tool em ~/.openclaw/completions/. Source condicional
# pra ficar inerte se desinstalado.

test -e $HOME/.openclaw/completions/openclaw.fish
and source $HOME/.openclaw/completions/openclaw.fish
