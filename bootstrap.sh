#!/bin/bash
# ────────────────────────────────────────────────────────────────────────────
# bootstrap.sh — Mac zero-to-hero bootstrap (Camada 1)
# ────────────────────────────────────────────────────────────────────────────
# Version: 0.1.0
# Repository: github.com/epoch-chrono/dotfiles
#
# Responsabilidade: levar um Mac recém-formatado até o ponto onde o Ansible
# pode tomar conta. Tudo que vier depois (brew, rosetta, defaults, mise,
# pacotes, chezmoi) é responsabilidade do playbook Ansible.
#
# Etapas v0.1.0 (até clone do repo):
#   1. Xcode Command Line Tools
#   2. Virtualenv isolado (~/.cache/dotfiles-bootstrap/venv)
#   3. Ansible-core no venv
#   4. Clone do repo dotfiles
#
# Etapas futuras (não implementadas nesta versão):
#   5. ansible-galaxy collection install
#   6. ansible-playbook (provisiona sistema + instala chezmoi)
#   7. chezmoi init --apply (deploy dos dotfiles)
#
# Uso:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/epoch-chrono/dotfiles/main/bootstrap.sh)"
#
# Modo paranoico (inspeciona antes de executar):
#   curl -fsSL -o /tmp/bootstrap.sh \
#     https://raw.githubusercontent.com/epoch-chrono/dotfiles/main/bootstrap.sh
#   less /tmp/bootstrap.sh
#   bash /tmp/bootstrap.sh
#
# Rollback:
#   rm -rf ~/.cache/dotfiles-bootstrap ~/.local/share/dotfiles
#   (CLT permanece instalado — é dependência universal e não causa problema)
# ────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Variáveis ───────────────────────────────────────────────────────────────
REPO_URL="https://github.com/epoch-chrono/dotfiles"
REPO_DIR="${HOME}/.local/share/dotfiles"
CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/dotfiles-bootstrap"
VENV_DIR="${CACHE_DIR}/venv"
LOG_DIR="${CACHE_DIR}/logs"
LOG_FILE="${LOG_DIR}/bootstrap-$(date +%Y%m%d-%H%M%S).log"

# ── Setup de log (tee para terminal + arquivo) ──────────────────────────────
mkdir -p "${LOG_DIR}"
exec > >(tee -a "${LOG_FILE}") 2>&1

# ── Banner inicial ──────────────────────────────────────────────────────────
echo "#============================================================#"
echo "#  bootstrap.sh v0.1.0 — Mac zero-to-hero"
echo "#  Início: $(date +%Y-%m-%dT%H:%M:%S%z)"
echo "#  Log:    ${LOG_FILE}"
echo "#  Repo:   ${REPO_URL}"
echo "#  Destino do clone: ${REPO_DIR}"
echo "#  Venv:   ${VENV_DIR}"
echo "#============================================================#"

# ── Etapa 1: Xcode Command Line Tools ───────────────────────────────────────
echo
echo "#--- $(date +%Y%m%d-%H%M%S) - Etapa 1: Xcode Command Line Tools ---#"

if xcode-select -p >/dev/null 2>&1; then
    echo "CLT já instalado em: $(xcode-select -p)"
    echo "Versão: $(/usr/bin/xcrun --version 2>/dev/null || echo 'desconhecida')"
else
    echo "CLT não detectado. Disparando instalador..."
    xcode-select --install
    echo
    echo "ATENÇÃO: a janela gráfica de instalação foi aberta."
    echo "         Aguarde a conclusão e rode este script novamente."
    exit 1
fi

# ── Etapa 2: Virtualenv isolado ─────────────────────────────────────────────
echo
echo "#--- $(date +%Y%m%d-%H%M%S) - Etapa 2: Virtualenv isolado para Ansible ---#"

if [ -d "${VENV_DIR}" ] && [ -f "${VENV_DIR}/bin/activate" ]; then
    echo "Venv já existe em ${VENV_DIR}, reusando."
else
    echo "Criando venv em ${VENV_DIR}..."
    mkdir -p "$(dirname "${VENV_DIR}")"
    python3 -m venv "${VENV_DIR}"
    echo "Venv criado."
fi

# shellcheck disable=SC1091
. "${VENV_DIR}/bin/activate"
echo "Venv ativado."
echo "Python: $(command -v python3) ($(python3 --version))"
echo "Pip:    $(command -v pip) ($(pip --version | awk '{print $2}'))"

# ── Etapa 3: Ansible-core no venv ───────────────────────────────────────────
echo
echo "#--- $(date +%Y%m%d-%H%M%S) - Etapa 3: Ansible-core no venv ---#"

echo "Atualizando pip..."
pip install --quiet --upgrade pip

echo "Instalando/atualizando ansible-core..."
pip install --quiet --upgrade ansible-core

echo "Instalado:"
ansible --version | sed 's/^/  /'

# ── Etapa 4: Clone do repo dotfiles ─────────────────────────────────────────
echo
echo "#--- $(date +%Y%m%d-%H%M%S) - Etapa 4: Clone do repo dotfiles ---#"

if [ -d "${REPO_DIR}/.git" ]; then
    echo "Repo já clonado em ${REPO_DIR}."
    echo "Atualizando com git pull --ff-only..."
    git -C "${REPO_DIR}" pull --ff-only
else
    echo "Clonando ${REPO_URL} em ${REPO_DIR}..."
    mkdir -p "$(dirname "${REPO_DIR}")"
    git clone "${REPO_URL}" "${REPO_DIR}"
fi

echo "Estado atual do repo:"
git -C "${REPO_DIR}" log --oneline -1 | sed 's/^/  /'
echo "  Branch: $(git -C "${REPO_DIR}" branch --show-current)"

# ── Banner final ────────────────────────────────────────────────────────────
echo
echo "#============================================================#"
echo "#  Bootstrap v0.1.0 concluído com sucesso"
echo "#  Fim: $(date +%Y-%m-%dT%H:%M:%S%z)"
echo "#"
echo "#  Próximas etapas (ainda NÃO implementadas):"
echo "#    5. ansible-galaxy collection install -r requirements.yml"
echo "#    6. ansible-playbook -i inventory/localhost.yml site.yml"
echo "#    7. chezmoi init --apply"
echo "#"
echo "#  Log salvo em: ${LOG_FILE}"
echo "#  Para limpar venv após uso: rm -rf ${CACHE_DIR}"
echo "#============================================================#"
