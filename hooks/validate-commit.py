#!/usr/bin/env python3
# ============================================================================
# validate-commit.py — guardrail de drift no commit (stage: pre-commit)
# ----------------------------------------------------------------------------
# SemVer: 1.0.0
#
# Valido duas invariantes do repo a cada commit, prevenindo os dois drifts
# recorrentes entre o source state e o que é materializado no $HOME:
#
#   CHECK 1 — Órfãos: todo rename/delete de arquivo chezmoi-materializado
#             precisa de uma entry correspondente no `.chezmoiremove` no
#             MESMO commit. Sem isso, o destination fica com arquivo órfão.
#
#   CHECK 2 — Bump: todo commit que altera state materializável (chezmoi
#             source OU playbook ansible) precisa bumpar a versão em
#             `ansible/site.yml` (linha `# Versão atual: X.Y.Z`) no MESMO
#             commit. Sem isso, a versão diverge do estado real.
#
# Leio o conteúdo STAGED via index (`git show :path`), então o resultado é
# correto mesmo com working tree sujo. Roda standalone ou via pre-commit
# (pass_filenames: false, always_run: true).
# ============================================================================

import subprocess
import sys

SITE_YML = "ansible/site.yml"
CHEZMOIREMOVE = ".chezmoiremove"
VERSION_MARKER = "# Versão atual:"

# Prefixos de atributo chezmoi (removidos no destination, mantêm o nome).
ATTR_PREFIXES = (
    "encrypted_", "private_", "readonly_", "executable_", "empty_",
    "exact_", "symlink_", "create_", "modify_", "remove_",
    "once_", "onchange_", "before_", "after_", "literal_",
)
# Prefixos que indicam arquivo gerenciado pelo chezmoi (1º segmento do path).
SOURCE_PREFIXES = ATTR_PREFIXES + ("dot_", "run_")

# Scaffolding do repo: não é dotfile materializado, nunca exige bump.
SCAFFOLD_FILES = {
    "README.md", "LICENSE", "Makefile", "mise.toml", "bootstrap.sh",
    ".pre-commit-config.yaml", ".gitleaks.toml", ".editorconfig", ".gitignore",
}
SCAFFOLD_DIRS = ("docs/", "hooks/")


def run(args):
    return subprocess.run(args, capture_output=True, text=True)


def staged_blob(path):
    """Conteúdo staged de um path (index). None se ausente no index."""
    r = run(["git", "show", f":{path}"])
    return r.stdout if r.returncode == 0 else None


def head_blob(path):
    """Conteúdo do path no HEAD. None se inexistente (ex: arquivo novo)."""
    r = run(["git", "show", f"HEAD:{path}"])
    return r.stdout if r.returncode == 0 else None


def first_segment(path):
    return path.split("/", 1)[0]


def is_chezmoi_source(path):
    seg = first_segment(path)
    return seg.startswith(SOURCE_PREFIXES) or seg.startswith(".chezmoi")


def is_materialized(path):
    """Source que vira arquivo em $HOME (exclui run_* e meta .chezmoi*)."""
    if not is_chezmoi_source(path):
        return False
    seg = first_segment(path)
    return not seg.startswith("run_") and not seg.startswith(".chezmoi")


def is_scaffold(path):
    return path in SCAFFOLD_FILES or path.startswith(SCAFFOLD_DIRS)


def is_materializable_change(path):
    """Mudança que exige bump: chezmoi source OU ansible/**, menos scaffold
    e o próprio site.yml (cuja edição É o bump)."""
    if path == SITE_YML or is_scaffold(path):
        return False
    return is_chezmoi_source(path) or path.startswith("ansible/")


def decode_target(source_path):
    """Traduz um source path chezmoi pro path relativo a $HOME.
    Ex: private_dot_ssh/config -> .ssh/config ; dot_config/x.tmpl -> .config/x"""
    out = []
    for seg in source_path.split("/"):
        changed = True
        while changed:
            changed = False
            for p in ATTR_PREFIXES:
                if seg.startswith(p):
                    seg = seg[len(p):]
                    changed = True
            if seg.startswith("dot_"):
                seg = "." + seg[len("dot_"):]
                changed = True
        out.append(seg)
    target = "/".join(out)
    if target.endswith(".tmpl"):
        target = target[: -len(".tmpl")]
    return target


def staged_changes():
    """Lista (status, path, old_path|None) das mudanças staged, com rename."""
    r = run(["git", "diff", "--cached", "--name-status", "-M"])
    changes = []
    for line in r.stdout.splitlines():
        parts = line.split("\t")
        status = parts[0]
        if status.startswith("R") and len(parts) == 3:
            changes.append((status, parts[2], parts[1]))   # (R, new, old)
        elif status.startswith("C") and len(parts) == 3:
            changes.append((status, parts[2], None))
        elif len(parts) == 2:
            changes.append((status, parts[1], None))
    return changes


def chezmoiremove_lines():
    """Entries staged do .chezmoiremove (sem comentários/vazias)."""
    blob = staged_blob(CHEZMOIREMOVE) or ""
    return {
        ln.strip() for ln in blob.splitlines()
        if ln.strip() and not ln.strip().startswith("#")
    }


def site_version(blob):
    if blob is None:
        return None
    for ln in blob.splitlines():
        if ln.strip().startswith(VERSION_MARKER):
            return ln.split(VERSION_MARKER, 1)[1].strip()
    return None


def main():
    changes = staged_changes()
    if not changes:
        return 0

    paths = {p for _, p, _ in changes}
    errors = []
    warnings = []

    # ── CHECK 1 — órfãos ────────────────────────────────────────────────
    removed = []           # source paths materializados que somem do source
    for status, path, old in changes:
        if status == "D" and is_materialized(path):
            removed.append(path)
        elif status.startswith("R") and old and is_materialized(old):
            removed.append(old)

    if removed:
        rm_entries = chezmoiremove_lines()
        rm_staged = CHEZMOIREMOVE in paths
        for src in removed:
            target = decode_target(src)
            if target in rm_entries:
                continue
            if rm_staged:
                warnings.append(
                    f"'{src}' removido/renomeado; '.chezmoiremove' foi alterado "
                    f"mas não achei a linha exata '{target}' (ok se coberto por glob)."
                )
            else:
                errors.append(
                    f"'{src}' foi removido/renomeado mas '.chezmoiremove' não "
                    f"foi alterado neste commit.\n"
                    f"    Adicione a linha ao '.chezmoiremove':\n"
                    f"      {target}"
                )

    # ── CHECK 2 — bump de versão ────────────────────────────────────────
    materializable = sorted(p for p in paths if is_materializable_change(p))
    if materializable:
        old_v = site_version(head_blob(SITE_YML))
        new_v = site_version(staged_blob(SITE_YML))
        if SITE_YML not in paths or new_v is None or new_v == old_v:
            sample = "\n".join(f"      {p}" for p in materializable[:8])
            extra = "" if len(materializable) <= 8 else f"\n      (+{len(materializable) - 8} arquivo(s))"
            errors.append(
                "Há mudança de state materializável sem bump de versão em "
                f"'{SITE_YML}'.\n"
                f"    Versão atual no HEAD: {old_v or '?'}\n"
                f"    Atualize a linha '{VERSION_MARKER} X.Y.Z' (e o changelog).\n"
                f"    Arquivos materializáveis neste commit:\n{sample}{extra}"
            )

    for w in warnings:
        print(f"[validate-commit] aviso: {w}", file=sys.stderr)

    if errors:
        print("\n[validate-commit] commit bloqueado:\n", file=sys.stderr)
        for i, e in enumerate(errors, 1):
            print(f"  {i}. {e}\n", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
