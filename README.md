# dotfiles

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/), secured with [1Password](https://1password.com), and built for reproducibility.

One command. Any machine. Same environment.

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/epoch-chrono/dotfiles/main/bootstrap.sh)"
```

## What's inside

- **Shell:** [Fish](https://fishshell.com/) with [Fisher](https://github.com/jorgebucaran/fisher), [Tide](https://github.com/IlanCosman/tide) prompt, and custom functions
- **Editor:** [Cursor](https://cursor.sh/) (macOS), [Helix](https://helix-editor.com/) (terminal)
- **Toolchain:** [mise](https://mise.jdx.dev/) for runtime/tool management — no more `nvm`, `pyenv`, `goenv`
- **Git:** templated config with per-context identity (personal / client) via 1Password
- **Security:** [gitleaks](https://github.com/gitleaks/gitleaks) + [pre-commit](https://pre-commit.com/) + [ShellCheck](https://www.shellcheck.net/) — secrets never touch the repo

## Platforms

| Platform | Arch | Package Manager |
|---|---|---|
| macOS (Sonoma+) | ARM64 | Homebrew |
| NixOS | x86_64 / ARM64 | Nix |
| Debian/Ubuntu | x86_64 / ARM64 | apt |

See [docs/PLATFORMS.md](docs/PLATFORMS.md) for details.

## How it works

```
bootstrap.sh                        # Installs git, curl, fish, chezmoi
  └─ chezmoi init --apply           # Clones this repo, processes templates
      ├─ run_once_before_00-*       # Installs mise + tools
      ├─ run_once_before_01-*       # Sets up fish (fisher, plugins)
      ├─ .chezmoi.yaml.tmpl        # Detects OS, prompts for context
      └─ *.tmpl                     # Templates resolved via 1Password
```

Templates reference 1Password items — secrets are resolved at apply time, never stored:

```
# dot_gitconfig.tmpl
[user]
  email = {{ onepasswordRead "op://personal/git/email" }}
```

See [docs/SECRETS.md](docs/SECRETS.md) for the full security model.

## Directory taxonomy

This repo follows a unified taxonomy (v1) for organizing projects and configs:

```
~/Git/
├── 000-personal.d/       # Personal projects
├── 100-professional.d/   # Professional umbrella
│   ├── 00-epoch.d/       #   Anchor — own company
│   └── 01-<client>.d/    #   Active clients
├── 900-archive.d/        # Frozen projects/clients
└── 999-sandbox.d/        # Experiments, throwaway
```

3-digit ranges at root level, 2-digit sequential inside professional. `.d` suffix marks organizational directories.

## Day-to-day usage

```sh
make apply     # Apply dotfiles to $HOME
make diff      # Preview what would change
make status    # Show managed file status
make update    # Pull latest + apply
make lint      # Run all pre-commit hooks
make doctor    # Health check (chezmoi, mise, fish, op)
make help      # Show all commands
```

## Adding a new dotfile

```sh
# Add an existing file
chezmoi add ~/.config/helix/config.toml

# Add as a template (for files with secrets)
chezmoi add --template ~/.gitconfig

# Edit in source, then apply
chezmoi edit ~/.config/fish/config.fish
chezmoi apply
```

## Stack

| Tool | Purpose |
|---|---|
| [chezmoi](https://www.chezmoi.io/) | Dotfile management, templating, 1Password integration |
| [mise](https://mise.jdx.dev/) | Tool/runtime version manager (replaces asdf, nvm, pyenv) |
| [Fish](https://fishshell.com/) | Shell |
| [1Password CLI](https://developer.1password.com/docs/cli/) | Secrets resolution at apply time |
| [pre-commit](https://pre-commit.com/) | Git hooks framework |
| [gitleaks](https://github.com/gitleaks/gitleaks) | Secret scanning |
| [ShellCheck](https://www.shellcheck.net/) | Shell script linting |
| [Conventional Commits](https://www.conventionalcommits.org/) | Commit message standard |

## Commit convention

```
feat(fish): add function for project navigation
fix(cursor): correct font family fallback
chore(pre-commit): update gitleaks to v8.x
docs: add NixOS platform notes
```

Scopes: `fish`, `cursor`, `helix`, `git`, `mise`, `brew`, `nix`, `bootstrap`, `pre-commit`.

## License

[MIT](LICENSE)
