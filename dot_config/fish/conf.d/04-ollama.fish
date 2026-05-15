# ──────────────────────────────────────────────────────────────────────────
# ~/.config/fish/conf.d/04-ollama.fish
# Managed by chezmoi: github.com/epoch-chrono/dotfiles
# ──────────────────────────────────────────────────────────────────────────
# Ollama — local inference (https://ollama.com).
#
# Env vars setadas mesmo sem ollama instalado: são vars que só valem quando
# `ollama` ou clients (langchain, llm tool, etc.) são invocados. Custo zero
# se ollama ausente.
#
# OLLAMA_HOST:           bind/connect address. 127.0.0.1:11434 = localhost
#                        default port. Mudar pra 0.0.0.0:11434 se quiser
#                        expor pra LAN (cuidado: sem auth nativa).
#
# OLLAMA_KEEP_ALIVE:     tempo que modelo fica em VRAM/RAM após última req.
#                        5m = balance entre latência (reload custa segundos)
#                        e ocupação de memória.
#
# OLLAMA_NUM_PARALLEL:   requests concorrentes processadas. 1 = serializado
#                        (default seguro pra M2 Pro com VRAM compartilhada).
#                        Aumentar quando rodar em desktop com RTX 4090 dedicada.

set -gx OLLAMA_HOST 127.0.0.1:11434
set -gx OLLAMA_KEEP_ALIVE 5m
set -gx OLLAMA_NUM_PARALLEL 1
