#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────────
# 20c-functions.bash.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.bash' não casa com '*.bash.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  professional  (configurações de cliente/profissional (escopo por entidade))
#   Stage:   20  (functions)
#   Shell:   bash
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 20c-functions.bash.tpl ../<scope-dir>/20c-functions.bash
#   3. chmod 0644 no destino pra poder editar.
#   4. Substitua o conteúdo do bloco "Body" pelos comandos reais.
#
# Edições neste arquivo serão sobrescritas pelo chezmoi no próximo apply
# (esta versão é a canônica no repo, não no Mac).
# ────────────────────────────────────────────────────────────────────────


# ── Propósito ──────────────────────────────────────────────────────────────
# Funções shell custom.
# Funções pequenas/médias que ganham em estar definidas eagerly.


# ── Conteúdo típico ────────────────────────────────────────────────────────
# Functions de uso frequente, helpers locais ao usuário, wrappers de
# tools que recebem args complexos.


# ── Boas práticas (bash) ───────────────────────────────────────────────────
# Functions com `function name() { ... }` ou `name() { ... }`.
# Locals com `local var=...`.
# Sempre quote os args: `"$@"` ou `"$1"`.
# Evite globals — exporte só se realmente precisar.


# ── Exemplos comentados (bash, professional) ───────────────────────────────
# # function <client>-ssm() {
# #     local target="$1"
# #     aws --profile <client> ssm start-session --target "$target"
# # }


# ── Body — adicione comandos abaixo ────────────────────────────────────────

