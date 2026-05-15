#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────────
# 40c-completions.bash.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.bash' não casa com '*.bash.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  professional  (configurações de cliente/profissional (escopo por entidade))
#   Stage:   40  (completions)
#   Shell:   bash
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 40c-completions.bash.tpl ../<scope-dir>/40c-completions.bash
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


# ── Boas práticas (bash) ───────────────────────────────────────────────────
# Use `[[ -f <file> ]] && source <file>` (guard).
# Bash completion via package; aqui só pra integrations adicionais.


# ── Exemplos comentados (bash, professional) ───────────────────────────────
# # [[ -f "$HOME/.config/<client>/completions.bash" ]] && \
# #     source "$HOME/.config/<client>/completions.bash"


# ── Body — adicione comandos abaixo ────────────────────────────────────────

