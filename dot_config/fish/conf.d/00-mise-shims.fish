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


# 3-4. Forçar ordem do PATH em fish_user_paths universal var.
#
# PROBLEMA: fish_user_paths é universal (persiste entre sessões em
# ~/.config/fish/fish_variables) e é PREPENDED ao $PATH antes dos conf.d
# rodarem. Se entries históricas estão em ordem errada (resíduo de
# instalações, intervenções manuais, brew upgrades), o PATH inicial fica
# errado e `fish_add_path --prepend` sem --move não corrige (é idempo-
# tente, só skipa se entry existe).
#
# SOLUÇÃO: `--move` flag força a reordenação. Cada `fish_add_path
# --prepend --move <path>` remove de qualquer posição anterior e adiciona
# na frente. Como cada call empurra a anterior, a ordem aplicada é
# INVERSA da ordem final desejada — fazemos da MAIS-AO-FUNDO pra
# MAIS-NA-FRENTE.
#
# Ordem final no fish_user_paths (que vira início do $PATH):
#   1º: ~/.local/bin             (preferido — mise binary mora aqui)
#   2º: ~/bin                    (scripts pessoais; pula se dir não existe)
#   3º: ~/.local/share/mise/shims (1 entry resolve qualquer tool do mise)
#   4º: /opt/homebrew/bin        (brew formulas)
#   5º: /opt/homebrew/sbin       (brew daemons/services)
#
# `test -d` evita adicionar dirs inexistentes (ex.: ~/bin se nunca foi
# criado).

# Ordem REVERSA do final desejado (último --move fica 1º):
test -d /opt/homebrew/sbin                  ; and fish_add_path --prepend --move /opt/homebrew/sbin
test -d /opt/homebrew/bin                   ; and fish_add_path --prepend --move /opt/homebrew/bin
test -d $HOME/.local/share/mise/shims       ; and fish_add_path --prepend --move $HOME/.local/share/mise/shims
test -d $HOME/bin                           ; and fish_add_path --prepend --move $HOME/bin
test -d $HOME/.local/bin                    ; and fish_add_path --prepend --move $HOME/.local/bin
