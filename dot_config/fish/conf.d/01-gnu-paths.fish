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
# e às vezes incompatíveis com scripts/exemplos que assumem GNU. Diferenças
# típicas que mordem:
#
#   sed:    -i sem argumento (BSD pede backup ext), regex POSIX vs ERE
#   tar:    --xattrs/--acls (GNU only), --transform (GNU only)
#   grep:   -P (PCRE) só no GNU
#   awk:    BSD awk não suporta -f profile / GNU extensions
#   find:   sintaxe -printf "%T@" só GNU
#
# Brew instala as versões GNU com prefixo "g" (gsed, gtar, gawk, gfind, etc.)
# Caveat sugere adicionar opt/<pkg>/libexec/gnubin ao PATH pra usar SEM o
# prefixo — substituindo as BSD.
#
#
# ORDEM TARGETED — replica do mac antigo do user
# -----------------------------------------------
# Mac antigo do user tem PATH na ordem:
#   ~/.local/bin → ~/bin → mise/shims → /opt/homebrew/bin → /opt/homebrew/sbin
#     → [11 GNU paths] → /usr/local/bin → /usr/bin → ...
#
# Ou seja, GNU paths ficam DEPOIS de brew bin/sbin (que vêm do brew shellenv
# rodado cedo no fish startup) e ANTES dos system dirs.
#
# Tentar usar `fish_add_path --prepend` colocaria GNU paths NO INÍCIO do PATH,
# antes inclusive de mise/shims e user dirs — incorreto.
#
# Solução: manipular o array $PATH diretamente, inserindo os GNU paths LOGO
# APÓS /opt/homebrew/sbin (último brew bin), preservando o resto.


# Lista NA ORDEM FINAL desejada (top = mais prioritário entre os GNU paths).
# Mesma ordem que o mac antigo do user, sem postgresql@18 (que é específico
# de instalação manual dele, não generalizável).
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

# Filtrar: só adiciona paths que existem no filesystem E ainda não estão no
# PATH (pra idempotência — se conf.d roda duas vezes não duplica).
set -l _new_paths
for _p in $_gnu_paths
    if test -d $_p; and not contains -- $_p $PATH
        set -a _new_paths $_p
    end
end

# Encontrar índice de /opt/homebrew/sbin (anchor pós-brew). Se ausente, fall-
# back pra /opt/homebrew/bin. Se nenhum dos dois existe, fall-back final
# pro fim do PATH (append).
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

# Limpeza de variáveis locais
set -e _gnu_paths
set -e _new_paths
set -e _p
set -e _anchor_idx
