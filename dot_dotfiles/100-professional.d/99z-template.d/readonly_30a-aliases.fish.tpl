#!/usr/bin/env fish
# ────────────────────────────────────────────────────────────────────────
# 30a-aliases.fish.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.fish' não casa com '*.fish.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  professional  (configurações de cliente/profissional (escopo por entidade))
#   Stage:   30  (aliases)
#   Shell:   fish
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 30a-aliases.fish.tpl ../<scope-dir>/30a-aliases.fish
#   3. chmod 0644 no destino pra poder editar.
#   4. Substitua o conteúdo do bloco "Body" pelos comandos reais.
#
# Edições neste arquivo serão sobrescritas pelo chezmoi no próximo apply
# (esta versão é a canônica no repo, não no Mac).
# ────────────────────────────────────────────────────────────────────────


# ── Propósito ──────────────────────────────────────────────────────────────
# Aliases e abbreviations.
# Substituições curtas pra comandos longos / frequentes.


# ── Conteúdo típico ────────────────────────────────────────────────────────
# Shortcuts de comandos frequentes: git, kubectl, terraform, etc.


# ── Boas práticas (fish) ───────────────────────────────────────────────────
# PREFIRA `abbr -a` sobre `alias`. Abbreviations expandem no
# command-line (UX melhor: você vê o comando completo antes de
# rodar, e elas funcionam dentro de aspas/scripts).
# `alias` em Fish é syntactic sugar pra function — não tem ganho.
# `abbr --query` lista, `abbr --erase <name>` remove.


# ── Exemplos comentados (fish, professional) ───────────────────────────────
# # abbr -a aws-<client> 'aws --profile <client>'
# # abbr -a k-<client> 'kubectl --context <client>-prod'
# # abbr -a ssm-<client> 'aws --profile <client> ssm start-session --target'


# ── Body — adicione comandos abaixo ────────────────────────────────────────

