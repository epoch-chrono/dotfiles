#!/usr/bin/env fish
# ────────────────────────────────────────────────────────────────────────
# 40a-post.fish.tpl
# ────────────────────────────────────────────────────────────────────────
# Template (não-funcional). Sufixo .tpl impede o loader de sourcear
# (find ... -iname '*.fish' não casa com '*.fish.tpl').
#
# Materializado como read-only (0444) pelo chezmoi via prefixo `readonly_`.
#
#   Escopo:  professional  (configurações de cliente/profissional (escopo por entidade))
#   Stage:   40  (post)
#   Shell:   fish
#
# Pra usar:
#   1. Crie um dir de escopo irmão (ex: 01-cliente-foo.d/, ou direto
#      em 000-personal.d/ se for fragment pessoal direto).
#   2. Copie este arquivo pra lá REMOVENDO o sufixo .tpl:
#        cp 40a-post.fish.tpl ../<scope-dir>/40a-post.fish
#   3. chmod 0644 no destino pra poder editar.
#   4. Substitua o conteúdo do bloco "Body" pelos comandos reais.
#
# NOTA: stage `functions` (que existia em v1.0) foi REMOVIDO. Functions de
# qualquer shell vivem em ~/.config/{fish,zsh,bash}/functions/<name>.fish.
# Ver docs/TAXONOMY.md → 'Functions: exceção à regra ~/.dotfiles/'.
# ────────────────────────────────────────────────────────────────────────


# ── Propósito ──────────────────────────────────────────────────────────────
# Cleanups, dedup, late overrides.
# Roda DEPOIS de todos os outros stages — última chance de ajustar.


# ── Conteúdo típico ────────────────────────────────────────────────────────
# PATH dedupe, remoção de vars temporárias, overrides finais que
# precisam sobrescrever algo setado por algum stage anterior ou plugin.


# ── Boas práticas (fish) ───────────────────────────────────────────────────
# Cuidado com side effects — mude só o que você tem certeza.
# Bom lugar pro PATH dedupe defensivo (vars universais persistentes).
# `set -e VAR` remove a var (local ou global).


# ── Exemplos comentados (fish, professional) ───────────────────────────────
# # # Override de prompt em sessões deste cliente
# # set -gx STARSHIP_CONFIG $HOME/.config/starship-<client>.toml


# ── Body — adicione comandos abaixo ────────────────────────────────────────

