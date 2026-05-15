#!/usr/bin/env zsh
# ────────────────────────────────────────────────────────────────────────
# 20b-functions.zsh.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.zsh' não casa com '*.zsh.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  professional  (configurações de cliente/profissional (escopo por entidade))
#   Stage:   20  (functions)
#   Shell:   zsh
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 20b-functions.zsh.tpl ../<scope-dir>/20b-functions.zsh
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


# ── Boas práticas (zsh) ────────────────────────────────────────────────────
# Functions com `function name() { ... }` ou `name() { ... }`.
# Locals com `local var=...`.
# Considere arquivo separado em `~/.zsh/functions/` com autoload.
# Sempre quote os args: `"$@"` ou `"$1"`.


# ── Exemplos comentados (zsh, professional) ────────────────────────────────
# # function <client>-ssm() {
# #     local target="$1"
# #     aws --profile <client> ssm start-session --target "$target"
# # }


# ── Body — adicione comandos abaixo ────────────────────────────────────────

