# Secrets Management

## Abordagem

Este repo é **público**. Nenhum secret é armazenado no repositório.

Secrets são gerenciados via [1Password CLI](https://developer.1password.com/docs/cli/) (`op`)
integrado nativamente com o [chezmoi](https://www.chezmoi.io/user-guide/password-managers/1password/).

## Como funciona

Templates `.tmpl` contêm **referências** a items do 1Password, não os secrets em si:

```
# Exemplo em dot_gitconfig.tmpl
[user]
  email = {{ onepasswordRead "op://personal/git/email" }}
  signingkey = {{ onepasswordRead "op://personal/git/signing-key" }}
```

Quando `chezmoi apply` é executado:

1. chezmoi encontra referências `onepasswordRead` / `onepassword`
2. Invoca `op` CLI que solicita autenticação (biométrica ou prompt)
3. Resolve o secret em memória e gera o arquivo final em `$HOME`
4. O secret nunca toca o disco como texto plano no repo

## Pré-requisitos

- [1Password](https://1password.com) com CLI (`op`) instalado
- Biometric unlock habilitado (recomendado) ou session token ativo
- Items referenciados existindo nos vaults corretos

## Quem clonar sem 1Password

O repo funciona normalmente para todo o conteúdo que **não depende de secrets**.
Templates com referências `op://` vão falhar no `chezmoi apply` — o chezmoi avisa quais
arquivos não puderam ser gerados. O resto aplica normalmente.

Para contribuidores, basta remover ou substituir as referências `op://` por valores locais.

## Vaults referenciados

| Vault | Uso |
|---|---|
| `personal` | Git config, SSH keys, API tokens pessoais |
| `clients/<slug>` | Credenciais específicas de clientes |

## Testando templates

```sh
# Verifica se o template resolve sem erros
chezmoi execute-template < dot_gitconfig.tmpl

# Dry-run: mostra o que seria gerado sem aplicar
chezmoi diff
```
