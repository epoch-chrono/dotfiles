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
# ORDEM (replica do mac antigo do user — PATH order no final, top = primeiro)
# ---------------------------------------------------------------------------
#   /opt/homebrew/opt/make/libexec/gnubin       (gmake → make)
#   /opt/homebrew/opt/libtool/libexec/gnubin    (glibtool, glibtoolize → libtool, libtoolize)
#   /opt/homebrew/opt/grep/libexec/gnubin       (ggrep, gegrep, gfgrep → grep, egrep, fgrep)
#   /opt/homebrew/opt/gpatch/libexec/gnubin     (gpatch → patch)
#   /opt/homebrew/opt/gnu-which/libexec/gnubin  (gwhich → which)
#   /opt/homebrew/opt/gnu-tar/libexec/gnubin    (gtar → tar)
#   /opt/homebrew/opt/gnu-sed/libexec/gnubin    (gsed → sed)
#   /opt/homebrew/opt/gnu-indent/libexec/gnubin (gindent → indent)
#   /opt/homebrew/opt/gawk/libexec/gnubin       (gawk → awk; gawk symlink permanece também)
#   /opt/homebrew/opt/findutils/libexec/gnubin  (gfind, glocate, gxargs → find, locate, xargs)
#   /opt/homebrew/opt/coreutils/libexec/gnubin  (ls, cp, mv, rm, dirname, basename, ... GNU)
#
# `fish_add_path --prepend` adiciona no início. Como fazemos prepend em
# loop, o ÚLTIMO prepended fica em primeiro. Pra match com ordem do mac
# antigo, a ordem do loop é INVERSA — coreutils primeiro no loop, make
# por último.
#
#
# CONVIVÊNCIA COM 00-mise-shims.fish
# ----------------------------------
# 00-mise-shims.fish roda ANTES deste arquivo (ordem alfabética em conf.d/).
# Ele adiciona ~/.local/bin, ~/bin e shims do mise. Depois deste arquivo,
# os GNU paths ficam ATRÁS desses user dirs no PATH:
#
#   ~/.local/bin → ~/bin → mise shims → make/libexec/gnubin → ...
#                                       libtool/libexec/gnubin → ...
#                                       (etc até coreutils/...) → /opt/homebrew/bin → ...
#
# Isso é exatamente a ordem do mac antigo do user, com mise shims no meio
# (que substitui o que ele tinha lá antes via outras tools de versionamento).


# Lista de GNU brews que têm libexec/gnubin. Ordem INVERSA da ordem final no
# PATH (último item do loop = primeiro no PATH após prepends).
set -l _gnu_brews \
    coreutils \
    findutils \
    gawk \
    gnu-indent \
    gnu-sed \
    gnu-tar \
    gnu-which \
    gpatch \
    grep \
    libtool \
    make

for _brew in $_gnu_brews
    set -l _gnubin /opt/homebrew/opt/$_brew/libexec/gnubin
    if test -d $_gnubin
        fish_add_path --prepend $_gnubin
    end
end

# Limpeza de variáveis locais (não vaza pra escopo do shell)
set -e _gnu_brews
set -e _brew
set -e _gnubin
