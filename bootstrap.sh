#!/bin/bash
# ────────────────────────────────────────────────────────────────────────────
# bootstrap.sh — zero-to-hero bootstrap (Camada 1)
# ────────────────────────────────────────────────────────────────────────────
# Version: 0.5.0
# Repository: github.com/epoch-chrono/dotfiles
#
# Responsabilidade: levar uma máquina recém-formatada (Mac ou Linux) até o
# ponto onde o Ansible pode tomar conta. Tudo que vier depois (brew, defaults,
# mise, pacotes, chezmoi) é responsabilidade do playbook Ansible.
#
# Etapas (todas as plataformas):
#   1. Pré-requisitos do SO
#        - macOS:  Xcode Command Line Tools (git, python3, clang, make)
#                  Tenta instalação headless via softwareupdate (funciona via
#                  SSH, sem GUI). Cai no xcode-select --install (modo GUI) se
#                  o headless falhar.
#        - Linux:  git, python3 + venv, build tools, ca-certificates
#   2. NOPASSWD sudo em /etc/sudoers.d/${USER}
#        - Pede senha 1x; daí em diante, sudo (incluindo Ansible) roda sem
#          prompt. Validação visudo -cf antes de instalar para evitar quebrar
#          sudo por sintaxe inválida.
#        - Opt-out: BOOTSTRAP_NOPASSWD_SUDO=0 bash bootstrap.sh
#        - NixOS: skip + orientação para configuration.nix
#   3. Rosetta 2 (somente Darwin ARM64)
#        - Headless via softwareupdate --install-rosetta --agree-to-license
#        - Skip em Linux, Mac Intel, e Mac ARM com Rosetta já presente
#        - Posicionado APÓS NOPASSWD para usar sudo sem prompt
#   4. Virtualenv isolado em ${XDG_CACHE_HOME:-~/.cache}/dotfiles-bootstrap/venv
#   5. Ansible-core no venv
#   6. Clone do repo dotfiles
#
# Etapas futuras (não implementadas nesta versão):
#   7. ansible-galaxy collection install
#   8. ansible-playbook (provisiona sistema + instala chezmoi)
#   9. chezmoi init --apply (deploy dos dotfiles)
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
#   sudo rm -f /etc/sudoers.d/$(id -un)            # remove NOPASSWD sudo
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
echo "#  bootstrap.sh v0.5.0 — zero-to-hero"
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

    echo "Xcode CLT não detectado."
    echo "Justificativa: sem CLT, /usr/bin/git e /usr/bin/python3 são stubs"
    echo "que disparam diálogo gráfico no primeiro uso, travando automação."
    echo

    # Tentativa 1: instalação headless via softwareupdate.
    # Funciona via SSH e em qualquer ambiente sem GUI session.
    # Referência: https://apple.stackexchange.com/q/107307
    echo "Tentando instalação headless via softwareupdate..."

    local marker="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    touch "${marker}"

    # softwareupdate -l só lista CLT se o marker acima existir.
    # Wrappar em `if` desabilita set -e/pipefail caso softwareupdate falhe
    # ou produza output inesperado.
    #
    # Formato moderno (macOS 12+) tem prefixo "Label: " antes do nome real:
    #   * Label: Command Line Tools for Xcode 26.4-26.4.1
    #     Title: Command Line Tools for Xcode, Version: 26.4, ...
    # O nome a ser passado pro `softwareupdate -i` é só o que vem depois
    # de "Label: " (sem o "Label: " literal).
    local prod=""
    local sw_output=""
    if sw_output=$(softwareupdate -l 2>/dev/null); then
        prod=$(printf '%s\n' "${sw_output}" \
            | awk -F'*' '/\*.*Command Line/ {print $2}' \
            | sed -E 's/^[[:space:]]+//; s/^Label:[[:space:]]*//' \
            | head -n 1 \
            | tr -d '\n' || true)
    fi

    if [ -n "${prod}" ]; then
        echo "Pacote identificado: ${prod}"
        echo "Instalando (sem prompt gráfico — pode demorar alguns minutos)..."

        # Captura output completo e exit code separadamente.
        # Não dá pra confiar só no exit code: softwareupdate -i pode retornar
        # 0 mesmo dizendo "No such update" no stdout.
        local sw_install_log=""
        local sw_install_rc=0
        if sw_install_log=$(softwareupdate -i "${prod}" --verbose 2>&1); then
            sw_install_rc=0
        else
            sw_install_rc=$?
        fi
        printf '%s\n' "${sw_install_log}"

        # Detecta sucesso real combinando 3 sinais: exit code, ausência de
        # mensagens de erro conhecidas, e disponibilidade do xcode-select.
        local install_failed=0
        if [ "${sw_install_rc}" -ne 0 ]; then
            echo "AVISO: softwareupdate -i retornou exit ${sw_install_rc}."
            install_failed=1
        elif printf '%s\n' "${sw_install_log}" \
                | grep -qE "(No such update|No updates? (are|is) available|cannot be downloaded|failed)"; then
            echo "AVISO: softwareupdate reportou exit 0 mas output indica falha."
            install_failed=1
        elif ! xcode-select -p >/dev/null 2>&1; then
            echo "AVISO: install completou sem erro mas xcode-select -p ainda falha."
            install_failed=1
        fi

        rm -f "${marker}"

        if [ "${install_failed}" -eq 0 ]; then
            echo "CLT instalado com sucesso (modo headless)."
            echo "Verificado: $(xcode-select -p)"
            return 0
        fi

        echo "Caindo no método GUI..."
    else
        echo "AVISO: softwareupdate -l não retornou pacote CLT."
        echo "       (formato de output pode ter mudado em macOS recente.)"
        echo "       Caindo no método GUI..."
        rm -f "${marker}"
    fi

    # Tentativa 2 (fallback): GUI dialog tradicional.
    # Esse método não funciona via SSH — requer sessão gráfica ativa.
    echo
    echo "Disparando instalador GUI via xcode-select..."
    xcode-select --install
    echo
    echo "ATENÇÃO: a janela gráfica de instalação foi aberta."
    echo "         Aguarde a conclusão e rode este script novamente."
    echo "         Se você está em SSH e não há sessão GUI, a janela não"
    echo "         vai aparecer e o headless acima é a única alternativa."
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

# ── Função: Rosetta 2 (Darwin ARM64 only) ───────────────────────────────────
install_rosetta() {
    # Cross-OS guard: Rosetta só existe no macOS
    if [ "${OS_NAME}" != "Darwin" ]; then
        echo "Não é macOS (${OS_NAME}). Rosetta não aplicável. Pulando."
        return 0
    fi

    # Architecture guard: Rosetta só faz sentido em Apple Silicon
    local arch
    arch="$(uname -m)"
    if [ "${arch}" != "arm64" ]; then
        echo "Mac é Intel (arch=${arch}). Rosetta desnecessária. Pulando."
        return 0
    fi

    # Idempotência: Apple cria /Library/Apple/usr/share/rosetta após instalar
    if [ -d /Library/Apple/usr/share/rosetta ]; then
        echo "Rosetta 2 já instalada (/Library/Apple/usr/share/rosetta presente)."
        echo "Pulando."
        return 0
    fi

    echo "Instalando Rosetta 2 (headless, --agree-to-license)..."
    echo "Justificativa: alguns binarios x86_64 ainda sao distribuidos"
    echo "(ferramentas comerciais especificas, builds antigas de pacotes brew,"
    echo "containers Docker x86). Rosetta permite rodar transparentemente."

    # softwareupdate --install-rosetta requer root no macOS atual.
    # Como esta etapa roda APOS NOPASSWD sudo (Etapa 2), nao ha prompt.
    sudo softwareupdate --install-rosetta --agree-to-license

    # Validação pós-install
    if [ -d /Library/Apple/usr/share/rosetta ]; then
        echo "Rosetta 2 instalada com sucesso."
    else
        die "softwareupdate completou mas /Library/Apple/usr/share/rosetta
       nao existe. Investigue manualmente."
    fi
}

# ── Função: NOPASSWD sudo (cross-OS) ────────────────────────────────────────
configure_passwordless_sudo() {
    if [ "${BOOTSTRAP_NOPASSWD_SUDO:-1}" != "1" ]; then
        echo "Configuração de NOPASSWD sudo desabilitada via"
        echo "BOOTSTRAP_NOPASSWD_SUDO=0. Pulando."
        return 0
    fi

    # NixOS: sudoers.d é resetado em nixos-rebuild — orientar config declarativa
    if [ "${OS_NAME}" = "Linux" ] && [ -e /etc/NIXOS ]; then
        echo "NixOS detectado. Configuração imperativa em /etc/sudoers.d/ é"
        echo "resetada em nixos-rebuild. Adicione em configuration.nix:"
        echo
        echo "  security.sudo.extraRules = [{"
        echo "    users = [ \"$(id -un)\" ];"
        echo "    commands = [{ command = \"ALL\"; options = [ \"NOPASSWD\" ]; }];"
        echo "  }];"
        echo
        echo "Pulando configuração imperativa."
        return 0
    fi

    local user_name
    user_name="$(id -un)"
    local sudoers_file="/etc/sudoers.d/${user_name}"
    local sudoers_line="${user_name} ALL=(ALL) NOPASSWD: ALL"

    # Idempotência: se já configurado, sudo -n cat consegue ler sem prompt
    if sudo -n cat "${sudoers_file}" 2>/dev/null | grep -qF "${sudoers_line}"; then
        echo "NOPASSWD sudo já configurado em ${sudoers_file}, pulando."
        return 0
    fi

    echo "Configurando NOPASSWD sudo para usuário '${user_name}'..."
    echo
    echo "ATENÇÃO: esta é a única vez que será solicitada senha de sudo no"
    echo "         setup. Após esta etapa, sudo (incluindo Ansible) roda"
    echo "         sem prompt."
    echo
    echo "Arquivo:  ${sudoers_file}"
    echo "Rollback: sudo rm ${sudoers_file}"
    echo "Opt-out:  BOOTSTRAP_NOPASSWD_SUDO=0 bash bootstrap.sh"
    echo

    # Tempfile com conteúdo + validação de sintaxe
    local tempfile
    tempfile=$(mktemp)
    {
        echo "# Configurado por bootstrap.sh em $(date +%Y-%m-%dT%H:%M:%S%z)"
        echo "# Para reverter: sudo rm ${sudoers_file}"
        echo "${sudoers_line}"
    } > "${tempfile}"

    # CRÍTICO: validar sintaxe ANTES de mover para /etc/sudoers.d/.
    # Sintaxe inválida em sudoers quebra `sudo` completamente até alguém
    # com acesso a single-user mode consertar. visudo -cf valida sem instalar.
    if ! sudo visudo -cf "${tempfile}" >/dev/null; then
        rm -f "${tempfile}"
        die "Sintaxe inválida no sudoers temporário. Abortando para evitar quebrar sudo."
    fi

    # Detectar group correto observando /etc/sudoers (Mac=wheel, Linux=root)
    local sudo_group="root"
    if stat -f '%Sg' /etc/sudoers >/dev/null 2>&1; then
        sudo_group="$(stat -f '%Sg' /etc/sudoers)"
    elif stat -c '%G' /etc/sudoers >/dev/null 2>&1; then
        sudo_group="$(stat -c '%G' /etc/sudoers)"
    fi

    # install -m 0440 atomicamente: copia + chmod + chown numa operação só
    sudo install -m 0440 -o root -g "${sudo_group}" "${tempfile}" "${sudoers_file}"
    rm -f "${tempfile}"

    # Validação pós-install: sudo -n true só passa se NOPASSWD funcionou
    if sudo -n true 2>/dev/null; then
        echo "NOPASSWD sudo configurado com sucesso."
        echo "Group do arquivo: ${sudo_group}"
    else
        die "Arquivo instalado em ${sudoers_file} mas 'sudo -n true' ainda
       pede senha. Pode haver outras regras em /etc/sudoers ou
       /etc/sudoers.d/ sobrescrevendo. Investigue manualmente."
    fi
}

# ── Etapa 1: Pré-requisitos do SO ───────────────────────────────────────────
log_step "Etapa 1: Pré-requisitos do SO (${OS_NAME})"

case "${OS_NAME}" in
    Darwin) install_prereqs_macos ;;
    Linux)  install_prereqs_linux ;;
    *)      die "SO não suportado: ${OS_NAME}" ;;
esac

# ── Etapa 2: NOPASSWD sudo ──────────────────────────────────────────────────
log_step "Etapa 2: NOPASSWD sudo (${OS_NAME})"
configure_passwordless_sudo

# ── Etapa 3: Rosetta 2 (somente Darwin ARM64) ──────────────────────────────
log_step "Etapa 3: Rosetta 2 (${OS_NAME} $(uname -m))"
install_rosetta

# ── Etapa 4: Virtualenv isolado ─────────────────────────────────────────────
log_step "Etapa 4: Virtualenv isolado para Ansible"

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

# ── Etapa 5: Ansible-core no venv ───────────────────────────────────────────
log_step "Etapa 5: Ansible-core no venv"

echo "Atualizando pip..."
pip install --quiet --upgrade pip

echo "Instalando/atualizando ansible-core..."
pip install --quiet --upgrade ansible-core

echo "Instalado:"
ansible --version | sed 's/^/  /'

# ── Etapa 6: Clone do repo dotfiles ─────────────────────────────────────────
log_step "Etapa 6: Clone do repo dotfiles"

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
echo "#  Bootstrap v0.5.0 concluído com sucesso"
echo "#  Fim: $(date +%Y-%m-%dT%H:%M:%S%z)"
echo "#"
echo "#  Próximas etapas (ainda NÃO implementadas):"
echo "#    7. ansible-galaxy collection install -r requirements.yml"
echo "#    8. ansible-playbook -i inventory/localhost.yml site.yml"
echo "#    9. chezmoi init --apply"
echo "#"
echo "#  Log salvo em: ${LOG_FILE}"
echo "#  Para limpar venv após uso: rm -rf ${CACHE_DIR}"
echo "#============================================================#"
