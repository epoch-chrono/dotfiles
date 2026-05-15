#!/usr/bin/env fish
# ────────────────────────────────────────────────────────────────────────
# 40a-completions.fish.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.fish' não casa com '*.fish.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  personal  (configurações pessoais (não vinculadas a cliente))
#   Stage:   40  (completions)
#   Shell:   fish
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 40a-completions.fish.tpl ../<scope-dir>/40a-completions.fish
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


# ── Boas práticas (fish) ───────────────────────────────────────────────────
# Use `test -e <file>; and source <file>` (guard portátil).
# Completions definidos com `complete -c <cmd> ...` PREFIRA ir
# em `~/.config/fish/completions/<cmd>.fish` (auto-load lazy).
# Aqui só pra: source de arquivos externos, integration scripts.


# ── Exemplos comentados (fish, personal) ───────────────────────────────────
# # test -e $HOME/.iterm2_shell_integration.fish
# # and source $HOME/.iterm2_shell_integration.fish
# #
# # test -e $HOME/.config/op/plugins.sh
# # and source $HOME/.config/op/plugins.sh
# #
# # test -e $HOME/.config/envman/load.fish
# # and source $HOME/.config/envman/load.fish


# ── Body — adicione comandos abaixo ────────────────────────────────────────

