# ─────────────────────────────────────────────────────────────────────────────
# fn-brew-compile-with
# ─────────────────────────────────────────────────────────────────────────────
# Ativa LDFLAGS/CPPFLAGS/PKG_CONFIG_PATH SÓ pros brews passados como args.
#
# Útil quando sabes exatamente qual lib precisas pra compilar:
#
#   fn-brew-compile-with openssl@3 readline
#   pip install psycopg2-binary
#   fn-brew-compile-env-off
#
# Idempotente: limpa as 3 vars ANTES de adicionar, então chamar 2 vezes
# resulta no estado da última chamada (não acumula).
#
# Sintaxe das flags do brew (todas aditivas):
#   LDFLAGS:         -L<path1> -L<path2> ... (compilador testa cada)
#   CPPFLAGS:        -I<path1> -I<path2> ...
#   PKG_CONFIG_PATH: <path1>:<path2>:...    (colon-separated, leftmost wins)
#
# Valida se cada brew existe via `brew --prefix <pkg>` (rápido, cached
# pelo brew). Skip silencioso de brews que não existem (não falha o
# comando inteiro).

function fn-brew-compile-with --description "Ativa flags de build pra brews específicos passados como args"
    if test (count $argv) -eq 0
        echo "Uso: fn-brew-compile-with <brew1> [<brew2> ...]" >&2
        echo "Exemplo: fn-brew-compile-with openssl@3 readline sqlite" >&2
        return 1
    end

    # Limpa estado anterior pra ser idempotente
    set -e LDFLAGS
    set -e CPPFLAGS
    set -e PKG_CONFIG_PATH

    set -l _ldflags
    set -l _cppflags
    set -l _pkg_config_paths
    set -l _applied_brews

    for _brew in $argv
        # `brew --prefix <pkg>` retorna o opt prefix ou erro se brew ausente
        set -l _prefix (brew --prefix $_brew 2>/dev/null)
        if test -z "$_prefix"
            continue  # brew não instalado, pula silenciosamente
        end

        # Adiciona LDFLAGS se lib/ existe
        if test -d $_prefix/lib
            set -a _ldflags "-L$_prefix/lib"
        end

        # Adiciona CPPFLAGS se include/ existe
        if test -d $_prefix/include
            set -a _cppflags "-I$_prefix/include"
        end

        # Adiciona PKG_CONFIG_PATH se lib/pkgconfig/ existe
        if test -d $_prefix/lib/pkgconfig
            set -a _pkg_config_paths $_prefix/lib/pkgconfig
        end

        set -a _applied_brews $_brew
    end

    # Exporta consolidado (string concat com separador apropriado)
    if test (count $_ldflags) -gt 0
        set -gx LDFLAGS (string join " " $_ldflags)
    end
    if test (count $_cppflags) -gt 0
        set -gx CPPFLAGS (string join " " $_cppflags)
    end
    if test (count $_pkg_config_paths) -gt 0
        set -gx PKG_CONFIG_PATH (string join ":" $_pkg_config_paths)
    end

    # Confirmação visual
    if test (count $_applied_brews) -gt 0
        echo "Build env ativado pra: "(string join ", " $_applied_brews)
        echo "  LDFLAGS=$LDFLAGS"
        echo "  CPPFLAGS=$CPPFLAGS"
        echo "  PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
        echo "Pra limpar: fn-brew-compile-env-off"
    else
        echo "Nenhum brew dos especificados está instalado: $argv" >&2
        return 1
    end
end
