#!/usr/bin/env fish
# ────────────────────────────────────────────────────────────────────────
# 10a-environment.fish.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.fish' não casa com '*.fish.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  professional  (configurações de cliente/profissional (escopo por entidade))
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


# ── Exemplos comentados (fish, professional) ───────────────────────────────
# # set -gx AWS_PROFILE <client-slug>-readonly
# # set -gx AWS_DEFAULT_REGION us-east-1
# # set -gx KUBECONFIG $HOME/.kube/<client>-config:$KUBECONFIG
# # set -gx ATLAS_PROJECT_ID <project-id>
# # set -gx <CLIENT>_DOMAIN <client>.example.com


# ── Body — adicione comandos abaixo ────────────────────────────────────────

