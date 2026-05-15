#!/usr/bin/env fish
# ────────────────────────────────────────────────────────────────────────
# 99a-others.fish.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.fish' não casa com '*.fish.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  professional  (configurações de cliente/profissional (escopo por entidade))
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
# NOTA: stage `functions` (que existia em v1.0) foi REMOVIDO. Functions de
# qualquer shell vivem em ~/.config/{fish,zsh,bash}/functions/<name>.fish.
# Ver docs/TAXONOMY.md → 'Functions: exceção à regra ~/.dotfiles/'.
# ────────────────────────────────────────────────────────────────────────


# ── Propósito ──────────────────────────────────────────────────────────────
# Catch-all para conteúdo que não cabe limpinho nos stages 00–40.
# Idealmente VAZIO — se tem conteúdo aqui, é débito técnico.


# ── Conteúdo típico ────────────────────────────────────────────────────────
# Coisas experimentais, snippets temporários, hacks one-off,
# código que você ainda não decidiu onde colocar.


# ── Boas práticas (fish) ───────────────────────────────────────────────────
# Tente NÃO usar. Cada coisa que entra aqui é candidato a
# promoção pra stage adequado (00–40).
# Se virar permanente, refatore.
# Bom uso: experiments curtos que você testa por alguns dias.


# ── Exemplos comentados (fish, professional) ───────────────────────────────
# # # Hack temporário pra debug de algum issue no cliente


# ── Body — adicione comandos abaixo ────────────────────────────────────────

