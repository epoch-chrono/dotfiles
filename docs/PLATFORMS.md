# Platform Support

## Plataformas suportadas

| Plataforma | Arch | Status | Package Manager |
|---|---|---|---|
| macOS (Sonoma+) | ARM64 (Apple Silicon) | Primary | Homebrew |
| NixOS | x86_64 / ARM64 | Active | Nix flake |
| Debian/Ubuntu | x86_64 / ARM64 | Supported | apt |
| Fedora/RHEL | x86_64 | Planned | dnf |
| Alpine | x86_64 / ARM64 | Planned | apk |

## Como funciona a detecção

O `.chezmoi.yaml.tmpl` detecta automaticamente:

```
os:       darwin | linux
arch:     amd64 | arm64
is_nixos: true | false (via /etc/NIXOS)
```

## Diferenças por plataforma

### macOS only

- `~/.cursor/` — Cursor IDE settings (ignorado no Linux via `.chezmoiignore`)
- Homebrew como base package manager
- `Library/` — macOS preferences (futuro)

### NixOS only

- Sistema gerenciado por Nix flake (pacotes, serviços, boot)
- `run_once_before_00-install-deps.sh` é **ignorado** (nix cuida)
- chezmoi gerencia apenas dotfiles de usuário

### Linux genérico (Debian, Fedora, etc.)

- Bootstrap completo via `bootstrap.sh`
- `build-essential` / `gcc` como dependência pra compilações nativas

## `.chezmoiignore` condicionais

Arquivos são condicionalmente ignorados baseado no OS:

```
# macOS-only — ignorado no Linux
{{ if ne .chezmoi.os "darwin" }}
dot_cursor/
{{ end }}

# NixOS — ignora bootstrap (nix gerencia deps)
{{ if .is_nixos }}
run_once_before_00-install-deps.sh.tmpl
{{ end }}
```

## Adicionando suporte a nova plataforma

1. Adicionar detecção no `bootstrap.sh` (bloco `install_system_packages`)
2. Testar: `chezmoi init --apply` numa VM limpa
3. Adicionar condicionais no `.chezmoiignore` se necessário
4. Documentar aqui
