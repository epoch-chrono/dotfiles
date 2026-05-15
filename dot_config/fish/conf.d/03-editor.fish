# ──────────────────────────────────────────────────────────────────────────
# ~/.config/fish/conf.d/03-editor.fish
# Managed by chezmoi: github.com/epoch-chrono/dotfiles
# ──────────────────────────────────────────────────────────────────────────
# Editor default: Helix (modal, hx binary).
# Docs: https://helix-editor.com
#
# Pré-requisito: helix instalado via mise/brew. Se ausente, EDITOR/VISUAL
# ficam unset — comandos que esperam editor (git commit, crontab -e, etc.)
# caem no default do sistema (vi/vim).
#
# Helix ≥25.x tem suporte nativo a atomic-save desabilitável em config.toml
# (resolve incompatibilidade com `crontab -e` e tools que validam inode
# stability). Já documentado nas memórias.

if command -q hx
    set -gx EDITOR hx
    set -gx VISUAL hx
end
