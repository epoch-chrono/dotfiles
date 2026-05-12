# dotfiles

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/), secured with [1Password](https://1password.com), and built for reproducibility.

One command. Any machine. Same environment.

## Quickstart

The bootstrap is a single bash script that provisions an isolated venv,
installs Ansible, clones this repo, and runs the playbook. It requires
two prerequisites on Linux: `curl` (or `wget`) to fetch the script,
and `python3`. macOS ships with both.

```sh
# 1. Define the hostname this machine should have (required)
export TARGET_HOSTNAME=mymachine

# 2. Provide a GitHub PAT (required — see below for how to create)
export GITHUB_API_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx

# 3. Run the bootstrap
bash -c "$(curl -fsSL https://raw.githubusercontent.com/epoch-chrono/dotfiles/main/bootstrap.sh)"
```

### GitHub PAT — how and why

The playbook installs ~90 tools via `mise install`, most of which are
downloaded from GitHub Releases. Anonymous requests are limited to **60
req/h per IP**, which breaks the install mid-way. Authenticated requests
get **5,000+ req/h**.

**Create a PAT with zero scopes** (rate limit elevation only — no extra
blast radius):

1. Open https://github.com/settings/tokens/new
2. **Description**: `mise-github-api`
3. **Expiration**: 1 year (rotate annually)
4. **Scopes**: leave **everything unchecked**. Public repos don't need
   any scope; authentication alone elevates rate limits.
5. Click "Generate token", copy `ghp_...`

After the first bootstrap, store the PAT in 1Password (the playbook is
already configured to read it via `op` as a fallback for interactive
runs — see `dot_config/mise/config.toml.tmpl`):

```sh
op item create --category 'API Credential' \
  --vault '00-personal/01-chezmoi' \
  --title 'api-key/github.com/<email>/chezmoi-bootstrap' \
  credential="$GITHUB_API_TOKEN"
```

### If `curl` is not available

On Ubuntu Server minimal and other lean Linux installs, `curl` may
be absent. Pick one:

```sh
# Option A — install curl first
sudo apt-get update && sudo apt-get install -y curl    # Debian/Ubuntu
sudo dnf install -y curl                                # Fedora/RHEL

# Option B — use wget (often pre-installed on Ubuntu)
export TARGET_HOSTNAME=mymachine
export GITHUB_API_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
bash -c "$(wget -qO- https://raw.githubusercontent.com/epoch-chrono/dotfiles/main/bootstrap.sh)"

# Option C — clone via git and run locally
sudo apt-get install -y git
git clone https://github.com/epoch-chrono/dotfiles.git ~/.local/share/dotfiles
cd ~/.local/share/dotfiles
TARGET_HOSTNAME=mymachine GITHUB_API_TOKEN=ghp_xxx bash bootstrap.sh
```

### Environment variables

| Variable | Required | Purpose |
|---|---|---|
| `TARGET_HOSTNAME` | yes (unless `BOOTSTRAP_RUN_PLAYBOOK=0`) | Hostname applied by the playbook (1-63 chars, `[a-zA-Z0-9-]+`) |
| `GITHUB_API_TOKEN` | yes (unless `BOOTSTRAP_RUN_PLAYBOOK=0`) | PAT for GitHub API rate limit elevation during `mise install`. No scopes needed. See section above. |
| `BOOTSTRAP_RUN_PLAYBOOK` | no | Set to `0` to skip the Ansible playbook (only run prereqs steps). Disables `TARGET_HOSTNAME` and `GITHUB_API_TOKEN` requirements. |
| `BOOTSTRAP_NOPASSWD_SUDO` | no | Set to `0` to skip configuring NOPASSWD sudo |

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

## Documentation

| Doc | Conteúdo |
|---|---|
| [docs/PLATFORMS.md](docs/PLATFORMS.md) | Plataformas suportadas, detecção, diferenças por OS |
| [docs/SECRETS.md](docs/SECRETS.md) | Gerenciamento de secrets via 1Password CLI |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Estado atual, próximas fatias, plano Nix, TODOs |

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
