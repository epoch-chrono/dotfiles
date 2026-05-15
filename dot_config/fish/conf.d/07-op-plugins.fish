# ──────────────────────────────────────────────────────────────────────────
# ~/.config/fish/conf.d/07-op-plugins.fish
# Managed by chezmoi: github.com/epoch-chrono/dotfiles
# ──────────────────────────────────────────────────────────────────────────
# 1Password CLI shell plugins
# Docs: https://developer.1password.com/docs/cli/shell-plugins/
#
# Substitui credenciais hardcoded de tools (aws, gh, jira, etc.) por
# lookups automáticos via `op`. Plugins configurados via `op plugin init
# <tool>` — daí cada call à tool dispara unlock biométrico se necessário.
#
# O arquivo plugins.sh é gerado pelo 1Password CLI. Apesar do nome .sh
# (default do op), funciona em fish via `source` direto (op gera sintaxe
# POSIX-portable: aliases + functions).
#
# Source guardado por `test -e` pra coexistir com hosts sem 1Password CLI
# (Dell NixOS pré-bootstrap, containers, CI runners).

test -e $HOME/.config/op/plugins.sh
and source $HOME/.config/op/plugins.sh
