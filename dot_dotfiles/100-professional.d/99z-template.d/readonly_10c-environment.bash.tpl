#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────────
# 10c-environment.bash.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.bash' não casa com '*.bash.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  professional  (configurações de cliente/profissional (escopo por entidade))
#   Stage:   10  (environment)
#   Shell:   bash
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 10c-environment.bash.tpl ../<scope-dir>/10c-environment.bash
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


# ── Boas práticas (bash) ───────────────────────────────────────────────────
# Exportadas: `export VAR=value`.
# PATH: `export PATH="<new>:$PATH"` (verificar duplicatas).
# Tools opcionais: `command -v <tool> >/dev/null && export ...`.


# ── Exemplos comentados (bash, professional) ───────────────────────────────
# # export AWS_PROFILE=<client-slug>-readonly
# # export AWS_DEFAULT_REGION=us-east-1
# # export KUBECONFIG="$HOME/.kube/<client>-config:$KUBECONFIG"


# ── Body — adicione comandos abaixo ────────────────────────────────────────

