# ─────────────────────────────────────────────────────────────────────────────
# brew-compile-env-off
# ─────────────────────────────────────────────────────────────────────────────
# Limpa LDFLAGS, CPPFLAGS e PKG_CONFIG_PATH setados por brew-compile-env ou
# brew-compile-with. Usar quando terminou de compilar e quer voltar ao
# ambiente default (sem build flags).
#
# Não diferencia entre vars setadas pelo brew-compile-* ou setadas
# manualmente — apaga tudo. Se precisa preservar vars manuais, salve em
# outras variáveis antes de chamar isto.

function brew-compile-env-off --description "Limpa LDFLAGS/CPPFLAGS/PKG_CONFIG_PATH setados por brew-compile-env*"
    set -e LDFLAGS
    set -e CPPFLAGS
    set -e PKG_CONFIG_PATH
    echo "Build env limpo (LDFLAGS, CPPFLAGS, PKG_CONFIG_PATH unset)"
end
