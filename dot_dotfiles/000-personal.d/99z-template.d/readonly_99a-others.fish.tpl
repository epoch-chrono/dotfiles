#!/usr/bin/env fish
# ────────────────────────────────────────────────────────────────────────
# 99a-others.fish.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.fish' não casa com '*.fish.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  personal  (configurações pessoais (não vinculadas a cliente))
#   Stage:   99  (others)
#   Shell:   fish
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 99a-others.fish.tpl ../<scope-dir>/99a-others.fish
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


# ── Boas práticas (fish) ───────────────────────────────────────────────────
# Tente NÃO usar. Cada coisa que entra aqui é candidato a
# promoção pra stage adequado (00–50).
# Se virar permanente, refatore.
# Bom uso: experiments curtos que você testa por alguns dias.


# ── Exemplos comentados (fish, personal) ───────────────────────────────────
# # # Exemplo: experiment de uma semana, mover depois pra stage real
# # function _experiment-foo
# #     echo 'testing'
# # end


# ── Body — adicione comandos abaixo ────────────────────────────────────────

