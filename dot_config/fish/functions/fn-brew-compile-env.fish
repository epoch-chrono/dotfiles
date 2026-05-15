# ─────────────────────────────────────────────────────────────────────────────
# fn-brew-compile-env
# ─────────────────────────────────────────────────────────────────────────────
# Ativa LDFLAGS/CPPFLAGS/PKG_CONFIG_PATH pra todos os brews de compilação
# comuns. Útil quando vai compilar algo que precisa de openssl, readline,
# sqlite, etc. do brew (em vez do sistema).
#
# Uso:
#   fn-brew-compile-env             # ativa pra todos os brews da lista
#   fn-brew-compile-env-off         # desativa (limpa as 3 vars)
#   fn-brew-compile-with <brew...>  # ativa SÓ pros brews passados como args
#
# Lista interna (`_brews`): brews que tipicamente são deps de build de Python,
# Ruby, Node, etc. compilados via pyenv/rbenv/asdf/mise (quando mise vai
# compilar Python 2.7.18 ou Ruby 3.4.x). Adicionar mais se descobrir caso.
#
# Idempotente: chamar duas vezes não duplica (limpa antes de aplicar).
#
# Trade-offs (porque NÃO setamos isso global):
#   - LDFLAGS/CPPFLAGS apontando pra múltiplos paths aumenta build time.
#   - Lib com mesmo nome em paths diferentes: pega a primeira no -L list.
#   - Alguns builds quebram se acharem header errado da lib do brew.
# Por isso fica como function ativável por demanda, não em conf.d global.

function fn-brew-compile-env --description "Ativa LDFLAGS/CPPFLAGS/PKG_CONFIG_PATH para brews de compilação comuns"
    set -l _brews \
        openssl@3 \
        openssl@1.1 \
        readline \
        sqlite \
        zlib \
        xz \
        bzip2 \
        libffi \
        ncurses \
        gettext \
        libtool

    fn-brew-compile-with $_brews
end
