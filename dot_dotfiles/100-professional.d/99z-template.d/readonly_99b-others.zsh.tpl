#!/usr/bin/env zsh
# ────────────────────────────────────────────────────────────────────────
# 99b-others.zsh.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.zsh' não casa com '*.zsh.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  professional  (configurações de cliente/profissional (escopo por entidade))
#   Stage:   99  (others)
#   Shell:   zsh
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 99b-others.zsh.tpl ../<scope-dir>/99b-others.zsh
#   3. chmod 0644 no destino pra poder editar.
#   4. Substitua o conteúdo do bloco "Body" pelos comandos reais.
#
# Edições neste arquivo serão sobrescritas pelo chezmoi no próximo apply
# (esta versão é a canônica no repo, não no Mac).
# ────────────────────────────────────────────────────────────────────────


# ── Propósito ──────────────────────────────────────────────────────────────
# Catch-all para conteúdo que não cabe limpinho nos stages 00–50.
# Idealmente VAZIO — se tem conteúdo aqui, é débito técnico.


# ── Conteúdo típico ────────────────────────────────────────────────────────
# Coisas experimentais, snippets temporários, hacks one-off,
# código que você ainda não decidiu onde colocar.


# ── Boas práticas (zsh) ────────────────────────────────────────────────────
# Tente NÃO usar. Cada coisa que entra aqui é candidato a
# promoção pra stage adequado (00–50).
# Se virar permanente, refatore.


# ── Exemplos comentados (zsh, professional) ────────────────────────────────
# # # Hacks temporários por cliente


# ── Body — adicione comandos abaixo ────────────────────────────────────────

