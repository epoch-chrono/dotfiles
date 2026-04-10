.PHONY: setup apply diff status update lint fmt help

# ── epoch-chrono/dotfiles ─────────────────────────
# make setup   → instala dependências e pre-commit
# make apply   → chezmoi apply (atualiza $HOME)
# make diff    → mostra o que mudaria
# make status  → arquivos gerenciados vs pendentes
# make update  → pull + apply
# make lint    → roda pre-commit em todos os arquivos
# make help    → mostra esta ajuda

setup:  ## Instala dependências e configura hooks
	@command -v mise >/dev/null 2>&1 && mise install || echo "mise não encontrado — instale: https://mise.run"
	@command -v pre-commit >/dev/null 2>&1 && pre-commit install || echo "pre-commit não encontrado — rode: mise install"
	@command -v chezmoi >/dev/null 2>&1 || (echo "chezmoi não encontrado" && exit 1)
	@echo ""
	@echo "✓ Setup completo."

apply:  ## Aplica dotfiles no \$$HOME
	chezmoi apply

diff:  ## Mostra diferenças entre source e destino
	chezmoi diff

status:  ## Mostra status dos arquivos gerenciados
	chezmoi status

update:  ## Pull do repo + apply
	chezmoi update

edit:  ## Abre o source dir no editor
	chezmoi cd

add:  ## Adiciona um arquivo ao chezmoi (uso: make add FILE=~/.gitconfig)
	@test -n "$(FILE)" || (echo "Uso: make add FILE=~/.gitconfig" && exit 1)
	chezmoi add $(FILE)

lint:  ## Roda pre-commit em todos os arquivos
	pre-commit run --all-files

fmt:  ## Formata arquivos (trailing whitespace, EOF, etc.)
	pre-commit run trailing-whitespace --all-files
	pre-commit run end-of-file-fixer --all-files
	pre-commit run mixed-line-ending --all-files

unmanaged:  ## Lista dotfiles no \$$HOME que o chezmoi não gerencia
	chezmoi unmanaged | grep -v -E "(cache|state|DS_Store|history)"

doctor:  ## Verifica saúde do chezmoi + dependências
	chezmoi doctor
	@echo ""
	@command -v mise >/dev/null 2>&1 && mise doctor || echo "mise: não encontrado"
	@command -v fish >/dev/null 2>&1 && echo "fish: $$(fish --version)" || echo "fish: não encontrado"
	@command -v op >/dev/null 2>&1 && echo "op: $$(op --version)" || echo "op: não encontrado"

help:  ## Mostra esta ajuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
