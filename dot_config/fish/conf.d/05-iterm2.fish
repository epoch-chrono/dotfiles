# ──────────────────────────────────────────────────────────────────────────
# ~/.config/fish/conf.d/05-iterm2.fish
# Managed by chezmoi: github.com/epoch-chrono/dotfiles
# ──────────────────────────────────────────────────────────────────────────
# iTerm2 shell integration — habilita features avançadas: mark/select de
# command output, alerts on command completion, automatic command-line
# marks, cursor shape per shell mode, etc.
# Docs: https://iterm2.com/documentation-shell-integration.html
#
# Instalado pelo iTerm2 via menu "Install Shell Integration", que escreve
# em ~/.iterm2_shell_integration.fish. Source guardado por `test -e` pra
# coexistir com:
#   - Dell NixOS (sem iTerm2)
#   - Sessões SSH dentro do iTerm2 (integration funciona via escape codes)
#   - Headless / non-tty (cron jobs, etc.)

test -e $HOME/.iterm2_shell_integration.fish
and source $HOME/.iterm2_shell_integration.fish
