#!/bin/bash
# ────────────────────────────────────────────────────────────────────────────
# bootstrap.sh — zero-to-hero bootstrap (Camada 1)
# ────────────────────────────────────────────────────────────────────────────
# Version: 0.2.0
# Repository: github.com/epoch-chrono/dotfiles
#
# Responsabilidade: levar uma máquina recém-formatada (Mac ou Linux) até o
# ponto onde o Ansible pode tomar conta. Tudo que vier depois (brew, rosetta,
# defaults, mise, pacotes, chezmoi) é responsabilidade do playbook Ansible.
#
# Etapas (todas as plataformas):
#   1. Pré-requisitos do SO
#        - macOS:  Xcode Command Line Tools (git, python3, clang, make)
#        - Linux:  git, python3 + venv, build tools, ca-certificates
#   2. Virtualenv isolado em ${XDG_CACHE_HOME:-~/.cache}/dotfiles-bootstrap/venv
#   3. Ansible-core no venv
#   4. Clone do repo dotfiles
#
# Etapas futuras (não implementadas nesta versão):
#   5. ansible-galaxy collection install
#   6. ansible-playbook (provisiona sistema + instala chezmoi)
#   7. chezmoi init --apply (deploy dos dotfiles)
#
# Plataformas suportadas:
#   - macOS (qualquer versão recente)
#   - Linux: Debian, Ubuntu, Mint, Pop!_OS, Raspbian (apt)
#            Fedora, RHEL, Rocky, AlmaLinux, CentOS (dnf)
#            Arch, Manjaro, EndeavourOS (pacman)
#            Alpine (apk)
#            openSUSE, SLES (zypper)
#            NixOS (modo verificação — prereqs em configuration.nix)
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
# Em Linux, sudo é obrigatório para instalar pacotes do SO. O script vai
# pedir senha uma vez no início.
#
# Rollback:
#   rm -rf ~/.cache/dotfiles-bootstrap ~/.local/share/dotfiles
#   (Pacotes do SO instalados na Etapa 1 permanecem — são deps universais.)
# ────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Variáveis ───────────────────────────────────────────────────────────────
REPO_URL="https://github.com/epoch-chrono/dotfiles"
REPO_DIR="${HOME}/.local/share/dotfiles"
CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/dotfiles-bootstrap"
VENV_DIR="${CACHE_DIR}/venv"
LOG_DIR="${CACHE_DIR}/logs"
LOG_FILE="${LOG_DIR}/bootstrap-$(date +%Y%m%d-%H%M%S).log"

OS_NAME="$(uname -s)"

# ── Setup de log (tee para terminal + arquivo) ──────────────────────────────
mkdir -p "${LOG_DIR}"
exec > >(tee -a "${LOG_FILE}") 2>&1

# ── Helpers ─────────────────────────────────────────────────────────────────
log_step() {
    echo
    echo "#--- $(date +%Y%m%d-%H%M%S) - $1 ---#"
}

die() {
    echo "ERRO: $1" >&2
    exit 1
}

# ── Banner inicial ──────────────────────────────────────────────────────────
echo "#============================================================#"
echo "#  bootstrap.sh v0.2.0 — zero-to-hero"
echo "#  Início:  $(date +%Y-%m-%dT%H:%M:%S%z)"
echo "#  SO:      ${OS_NAME}"
echo "#  Log:     ${LOG_FILE}"
echo "#  Repo:    ${REPO_URL}"
echo "#  Destino: ${REPO_DIR}"
echo "#  Venv:    ${VENV_DIR}"
echo "#============================================================#"

# ── Funções de pré-requisitos por SO ────────────────────────────────────────
install_prereqs_macos() {
    if xcode-select -p >/dev/null 2>&1; then
        echo "Xcode CLT já instalado em: $(xcode-select -p)"
        echo "Versão: $(/usr/bin/xcrun --version 2>/dev/null || echo 'desconhecida')"
        return 0
    fi

    echo "Xcode CLT não detectado. Disparando instalador..."
    echo "Justificativa: sem CLT, /usr/bin/git e /usr/bin/python3 são stubs"
    echo "que disparam diálogo gráfico no primeiro uso, travando automação."
    xcode-select --install
    echo
    echo "ATENÇÃO: a janela gráfica de instalação foi aberta."
    echo "         Aguarde a conclusão e rode este script novamente."
    exit 1
}

install_prereqs_linux() {
    # NixOS é especial: pacotes vêm via configuration.nix, não package manager.
    # Aqui só validamos que o que precisamos já está disponível.
    if [ -e /etc/NIXOS ]; then
        echo "NixOS detectado. Pulando install — prereqs precisam estar"
        echo "declarados em configuration.nix. Validando disponibilidade..."
        for cmd in git python3; do
            if ! command -v "${cmd}" >/dev/null 2>&1; then
                die "${cmd} não está em PATH. Adicione em configuration.nix e rebuild."
            fi
        done
        # python3-venv check (no NixOS, vem com python3)
        if ! python3 -c "import venv" >/dev/null 2>&1; then
            die "python3 não tem o módulo venv. Verifique o package python3 do NixOS."
        fi
        echo "OK — git, python3 e python3-venv disponíveis."
        return 0
    fi

    [ -f /etc/os-release ] || die "/etc/os-release ausente. Distro Linux não detectada."

    # shellcheck disable=SC1091
    . /etc/os-release
    echo "Distro detectada: ${NAME:-?} ${VERSION_ID:-?} (ID=${ID:-?})"

    # Resolver sudo (alguns containers não têm)
    local sudo=""
    if [ "$(id -u)" -ne 0 ]; then
        if command -v sudo >/dev/null 2>&1; then
            sudo="sudo"
        else
            die "Não está rodando como root e sudo não está disponível."
        fi
    fi

    case "${ID:-}" in
        debian|ubuntu|raspbian|pop|linuxmint|elementary)
            echo "Usando apt (Debian/Ubuntu family)."
            ${sudo} apt-get update -qq
            ${sudo} apt-get install -y -qq \
                git ca-certificates curl \
                python3 python3-venv python3-pip \
                build-essential
            ;;
        fedora|rhel|centos|rocky|almalinux)
            echo "Usando dnf (RHEL family)."
            ${sudo} dnf install -y -q \
                git ca-certificates curl \
                python3 python3-pip \
                gcc make
            ;;
        arch|manjaro|endeavouros|garuda)
            echo "Usando pacman (Arch family)."
            ${sudo} pacman -Sy --noconfirm --needed --quiet \
                git ca-certificates curl \
                python python-pip \
                base-devel
            ;;
        alpine)
            echo "Usando apk (Alpine)."
            ${sudo} apk add --quiet \
                git ca-certificates curl \
                python3 py3-pip py3-virtualenv \
                build-base
            ;;
        opensuse*|sles)
            echo "Usando zypper (SUSE family)."
            ${sudo} zypper --non-interactive --quiet install \
                git ca-certificates curl \
                python3 python3-pip python3-virtualenv \
                gcc make
            ;;
        *)
            die "Distro Linux '${ID:-?}' não suportada por este bootstrap.
      Suportadas: debian/ubuntu/mint/pop, fedora/rhel/rocky, arch/manjaro,
      alpine, opensuse/sles, nixos."
            ;;
    esac
}

# ── Etapa 1: Pré-requisitos do SO ───────────────────────────────────────────
log_step "Etapa 1: Pré-requisitos do SO (${OS_NAME})"

case "${OS_NAME}" in
    Darwin) install_prereqs_macos ;;
    Linux)  install_prereqs_linux ;;
    *)      die "SO não suportado: ${OS_NAME}" ;;
esac

# ── Etapa 2: Virtualenv isolado ─────────────────────────────────────────────
log_step "Etapa 2: Virtualenv isolado para Ansible"

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
log_step "Etapa 3: Ansible-core no venv"

echo "Atualizando pip..."
pip install --quiet --upgrade pip

echo "Instalando/atualizando ansible-core..."
pip install --quiet --upgrade ansible-core

echo "Instalado:"
ansible --version | sed 's/^/  /'

# ── Etapa 4: Clone do repo dotfiles ─────────────────────────────────────────
log_step "Etapa 4: Clone do repo dotfiles"

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
echo "#  Bootstrap v0.2.0 concluído com sucesso"
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
