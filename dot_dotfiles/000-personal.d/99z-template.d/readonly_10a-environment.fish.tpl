#!/usr/bin/env fish
# ────────────────────────────────────────────────────────────────────────
# 10a-environment.fish.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.fish' não casa com '*.fish.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  personal  (configurações pessoais (não vinculadas a cliente))
#   Stage:   10  (environment)
#   Shell:   fish
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 10a-environment.fish.tpl ../<scope-dir>/10a-environment.fish
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


# ── Boas práticas (fish) ───────────────────────────────────────────────────
# Exportadas: `set -gx VAR value`. Sem `x`: scoped ao shell.
# PATH: use `fish_add_path` (idempotente, não modifica $PATH direto).
# Tools opcionais: guard com `command -q <tool>; and set -gx ...`.
# Universal vars (`set -Ux`): persistem entre sessões — usar com cautela.


# ── Exemplos comentados (fish, personal) ───────────────────────────────────
# # set -gx EDITOR hx
# # set -gx VISUAL hx
# # set -gx OLLAMA_HOST 127.0.0.1:11434
# # set -gx OLLAMA_KEEP_ALIVE 5m
# # fish_add_path $HOME/.local/bin $HOME/bin
# # command -q antigravity; and fish_add_path $HOME/.antigravity/bin


# ── Body — adicione comandos abaixo ────────────────────────────────────────

