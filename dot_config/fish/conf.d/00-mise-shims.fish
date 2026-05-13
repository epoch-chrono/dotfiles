# ─────────────────────────────────────────────────────────────────────────────
# ~/.config/fish/conf.d/00-mise-shims.fish
# ─────────────────────────────────────────────────────────────────────────────
#
# Mise: usar modo --shims em vez do auto-activate full do vendor brew.
#
# PROBLEMA QUE ISSO RESOLVE
# -------------------------
# Quando mise vem do brew, ele instala vendor file em:
#   /opt/homebrew/share/fish/vendor_conf.d/mise.fish
# Que faz:
#   if [ "$MISE_FISH_AUTO_ACTIVATE" != "0" ]
#       /opt/homebrew/bin/mise activate fish | source
#   end
#
# `mise activate fish` (sem --shims) exporta UMA entrada PATH POR TOOL,
# inflando $PATH com 100+ entradas tipo:
#   ~/.local/share/mise/installs/python/3.13.11/bin
#   ~/.local/share/mise/installs/node/lts/bin
#   ... (etc)
# Side effects:
#   - PATH gigantesco, scripts que iteram $PATH ficam lentos
#   - IDEs/GUI apps (Cursor, Claude Code, VS Code) NÃO herdam esse PATH
#     em subprocess porque vem de shell interativo
#   - mise hook-env roda em cada prompt (custo CPU em shell startup)
#
# SOLUÇÃO: --shims mode
# ---------------------
# `mise activate fish --shims` adiciona APENAS uma entrada:
#   ~/.local/share/mise/shims
# Cada call a `python`, `node`, etc. passa pelo shim, que resolve a
# versão correta dinamicamente baseado em config.toml + .tool-versions
# encontrados na árvore de diretórios.
#
# Trade-off conhecido:
#   - Shims são ~30ms mais lentos por invocation (resolve a cada call)
#   - Pra fluxo dev interativo, imperceptível
#   - mise hook features (cd hooks, env vars por projeto via [env]) ainda
#     funcionam — shim faz mise resolve
#
# Ganhos:
#   - IDEs/GUI apps herdam o PATH com shims → resolvem tools no subprocess
#   - PATH compacto e legível
#   - Sem overhead de mise hook-env em cada prompt
#
#
# IMPLEMENTAÇÃO
# -------------
# Fish carrega conf.d em ordem:
#   1. /etc/fish/conf.d
#   2. /opt/homebrew/share/fish/vendor_conf.d  ← brew mise.fish aqui
#   3. ~/.config/fish/conf.d                    ← este arquivo aqui
#
# Vendor já rodou ANTES deste arquivo. Então na PRIMEIRA sessão depois do
# bootstrap, o PATH ainda fica explodido. Setamos MISE_FISH_AUTO_ACTIVATE=0
# como universal var (set -Ux) — persiste em ~/.config/fish/fish_variables
# e a partir da PRÓXIMA sessão o vendor pula o auto-activate, deixando
# este conf.d cuidar de tudo em modo --shims limpo.
#
# Pra forçar agora sem abrir nova sessão: `exec fish`.


# 1. Desabilita auto-activate do vendor mise.fish (próximas sessões).
#    `set -Ux` = universal (persiste em fish_variables) + exportada.
#    `set -q` ANTES garante idempotência — só seta se não existe.
if not set -q MISE_FISH_AUTO_ACTIVATE
    set -Ux MISE_FISH_AUTO_ACTIVATE 0
end


# 2. Ativa mise em modo --shims. Idempotente: chamar 2x não duplica entry.
#    `command -q mise` evita erro silencioso se mise não está instalado
#    (bootstrap muito early, ou se brew uninstall).
if command -q mise
    mise activate fish --shims | source
end


# 3. Garantir /opt/homebrew/sbin no PATH (defensivo).
#    Brew shellenv via vendor_conf.d/brew.fish tipicamente adiciona AMBOS
#    /opt/homebrew/bin e /opt/homebrew/sbin via `fish_add_path -gP`. Em
#    alguns setups (intervenção manual, fish_user_paths corrompido,
#    upgrade do brew), só /bin sobra. Insere /sbin logo após /bin se
#    ausente.
set -l _bin_idx (contains -i -- /opt/homebrew/bin $PATH)
if test -n "$_bin_idx"; and not contains -- /opt/homebrew/sbin $PATH
    set -gx PATH $PATH[1..$_bin_idx] /opt/homebrew/sbin $PATH[(math $_bin_idx + 1)..-1]
end


# 4. User-managed dirs NA FRENTE dos shims.
#    `fish_add_path --prepend` é IDEMPOTENTE: se entry já existe em
#    fish_user_paths (universal var) em posição errada, ele NÃO move por
#    default. Solução: `--move` flag força reordenação.
#    Resultado final no PATH:
#      1º: ~/.local/bin   (preferido — onde mise binary fica)
#      2º: ~/bin          (scripts pessoais; só adicionado se dir existe)
#      3º: shims (do mise activate --shims acima)
#      4º: /opt/homebrew/bin (do brew shellenv)
#      5º: /opt/homebrew/sbin (do passo 3)
#      ...
fish_add_path --prepend --move $HOME/bin
fish_add_path --prepend --move $HOME/.local/bin
