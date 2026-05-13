# ─────────────────────────────────────────────────────────────────────────────
# ~/.config/fish/conf.d/01-gnu-paths.fish
# ─────────────────────────────────────────────────────────────────────────────
#
# GNU coreutils, findutils, sed, tar, etc. — usar versões GNU como padrão
# em vez das BSD do macOS.
#
# CONTEXTO
# --------
# macOS vem com utilities BSD (sed, tar, awk, find, grep, etc.) — minimalistas
# e às vezes incompatíveis com scripts/exemplos que assumem GNU. Brew instala
# as versões GNU com prefixo "g" (gsed, gtar, gawk, gfind, etc.) e fornece
# uma versão "sem g" em opt/<pkg>/libexec/gnubin pra adicionar ao PATH.
#
#
# ORDEM TARGETED — replica do mac antigo do user
# -----------------------------------------------
# Posição relativa: ~/.local/bin → ~/bin → mise/shims → /opt/homebrew/bin →
# /opt/homebrew/sbin → [11 GNU paths] → /usr/local/bin → /usr/bin → ...
#
# Logo, GNU paths ficam DEPOIS de brew bin/sbin (que vêm via fish_user_paths
# universal, gerenciados pelo 00-mise-shims.fish) e ANTES de /usr/local/bin.
#
#
# PROBLEMA DE STATE PRÉVIO — fish_user_paths universal var
# ---------------------------------------------------------
# fish_user_paths é UNIVERSAL (persiste em ~/.config/fish/fish_variables)
# e é PREPENDED ao $PATH na inicialização do fish — ANTES dos conf.d
# rodarem.
#
# Se sessões anteriores adicionaram GNU paths ao fish_user_paths via
# fish_add_path (incluindo dotfile setups antigos do user), eles aparecem
# no $PATH em ordem ERRADA já no primeiro byte do conf.d. Como este script
# checa `not contains -- $_p $PATH` antes de adicionar, ele skipa porque
# eles JÁ ESTÃO no $PATH (em posição errada).
#
# SOLUÇÃO em 3 passos:
#   1. Remover GNU paths do fish_user_paths universal var
#   2. Remover GNU paths do $PATH session atual
#   3. Reinserir GNU paths no $PATH na posição correta (após /sbin)
#
# Reset do universal var é cirúrgico — não afeta outros paths.


# Lista canônica de GNU brews + paths (ordem final desejada no PATH,
# top = primeiro). Mesma ordem do mac antigo do user.
set -l _gnu_paths \
    /opt/homebrew/opt/make/libexec/gnubin \
    /opt/homebrew/opt/libtool/libexec/gnubin \
    /opt/homebrew/opt/grep/libexec/gnubin \
    /opt/homebrew/opt/gpatch/libexec/gnubin \
    /opt/homebrew/opt/gnu-which/libexec/gnubin \
    /opt/homebrew/opt/gnu-tar/libexec/gnubin \
    /opt/homebrew/opt/gnu-sed/libexec/gnubin \
    /opt/homebrew/opt/gnu-indent/libexec/gnubin \
    /opt/homebrew/opt/gawk/libexec/gnubin \
    /opt/homebrew/opt/findutils/libexec/gnubin \
    /opt/homebrew/opt/coreutils/libexec/gnubin


# 1. Limpa GNU paths do fish_user_paths universal. Loop while resolve
#    duplicatas (raro mas possível). Necessário pra evitar que próximas
#    sessões venham com GNU paths em posição errada novamente.
for _gnu in $_gnu_paths
    while set -l _idx (contains -i -- $_gnu $fish_user_paths)
        set --erase --universal fish_user_paths[$_idx]
    end
end


# 2. Limpa GNU paths do $PATH session atual. Reconstroi $PATH sem nenhum
#    GNU path — depois reinsere na posição correta (passo 3).
set -l _path_clean
for _p in $PATH
    if not contains -- $_p $_gnu_paths
        set -a _path_clean $_p
    end
end
set -gx PATH $_path_clean


# 3. Filtrar GNU paths que existem no filesystem (skip brews não instalados)
set -l _new_paths
for _p in $_gnu_paths
    if test -d $_p
        set -a _new_paths $_p
    end
end


# 4. Inserir após /opt/homebrew/sbin (anchor pós-brew). Fall-backs:
#      a. /opt/homebrew/bin (se sbin ausente)
#      b. append no fim do PATH (se nenhum brew bin presente — defensivo)
if test (count $_new_paths) -gt 0
    set -l _anchor_idx (contains -i -- /opt/homebrew/sbin $PATH)
    if test -z "$_anchor_idx"
        set _anchor_idx (contains -i -- /opt/homebrew/bin $PATH)
    end
    if test -n "$_anchor_idx"
        # Inserir _new_paths logo após o anchor:
        #   PATH antes: [... , anchor, X, Y, Z]
        #   PATH depois: [... , anchor, _new_paths..., X, Y, Z]
        set -gx PATH $PATH[1..$_anchor_idx] $_new_paths $PATH[(math $_anchor_idx + 1)..-1]
    else
        # Sem brew no PATH: append no fim (raro mas defensivo)
        set -gx PATH $PATH $_new_paths
    end
end


# Cleanup de variáveis locais
set -e _gnu_paths
set -e _new_paths
set -e _path_clean
set -e _p
set -e _gnu
set -e _idx
set -e _anchor_idx
