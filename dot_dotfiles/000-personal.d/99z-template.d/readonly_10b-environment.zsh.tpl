#!/usr/bin/env zsh
# ────────────────────────────────────────────────────────────────────────
# 10b-environment.zsh.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.zsh' não casa com '*.zsh.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  personal  (configurações pessoais (não vinculadas a cliente))
#   Stage:   10  (environment)
#   Shell:   zsh
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 10b-environment.zsh.tpl ../<scope-dir>/10b-environment.zsh
#   3. chmod 0644 no destino pra poder editar.
#   4. Substitua o conteúdo do bloco "Body" pelos comandos reais.
#
# Edições neste arquivo serão sobrescritas pelo chezmoi no próximo apply
# (esta versão é a canônica no repo, não no Mac).
# ────────────────────────────────────────────────────────────────────────


# ── Propósito ──────────────────────────────────────────────────────────────
# Variáveis de ambiente e adições ao PATH.
# Stage onde 90% das configurações vivem.


# ── Conteúdo típico ────────────────────────────────────────────────────────
# Env vars exportadas (visíveis a child processes), env vars de shell
# (locais à sessão), entries de PATH específicas, configuração de
# tools (homedir, region, kubeconfig, etc.).


# ── Boas práticas (zsh) ────────────────────────────────────────────────────
# Exportadas: `export VAR=value`. Locais: `VAR=value`.
# PATH: `path=(... $path)` ou `export PATH="...:$PATH"`.
# Tools opcionais: `command -v <tool> >/dev/null && export ...`.
# Use `typeset -U path` no início pra dedup automático do PATH.


# ── Exemplos comentados (zsh, personal) ────────────────────────────────────
# # export EDITOR=hx
# # export VISUAL=hx
# # export OLLAMA_HOST=127.0.0.1:11434
# # path=("$HOME/.local/bin" "$HOME/bin" $path)


# ── Body — adicione comandos abaixo ────────────────────────────────────────

