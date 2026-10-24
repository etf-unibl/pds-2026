#!/usr/bin/env python3
"""One-time initialization of a course repository created from the course template.

Run by .github/workflows/init-course.yml (on the main branch) right after the
repository is created with "Use this template". It replaces the template
placeholders with the values of the new repository and removes the
template-only content (instructor setup guide, template notice in README).
It also creates the labels of the course (labels.json next to this script):
a repository created from a template does not get the template's labels.

Usage:
    init_course.py --branch main|assignments --path <checkout> \
                   --org <org> --repo <repo> --year <year> --course <course> [--instructor <user>]
    init_course.py labels <labels.json> <owner/repo>     (token in GITHUB_TOKEN)
"""
import argparse
import json
import os
import pathlib
import re
import shutil
import sys
import urllib.error
import urllib.parse
import urllib.request

# Placeholders used in the student documentation (Serbian and English templates)
ORG_PLACEHOLDERS = ("<organizacija>", "<org>")
REPO_PLACEHOLDERS = ("<repozitorijum>", "<repo>")
# README title placeholders
COURSE_PLACEHOLDERS = ("<Naziv kursa>", "<Course name>")

TEMPLATE_BLOCK = re.compile(r"<!-- template:begin -->.*?<!-- template:end -->\n*", re.S)
TITLE_TODO = re.compile(r"^<!-- TODO \((nastavnik|instructor)\): (naziv kursa i godina izvođenja|course name and year) -->\n", re.M)
# Rows of the placeholder table in getting-started.md that no longer apply
PLACEHOLDER_ROW = re.compile(r"^\| `(" + "|".join(re.escape(p) for p in ORG_PLACEHOLDERS + REPO_PLACEHOLDERS) + r")` \|.*\n", re.M)


def read(path):
    return path.read_text(encoding="utf-8")


def write(path, text):
    path.write_text(text, encoding="utf-8", newline="\n")


def set_license_year(root, year):
    lic = root / "LICENSE"
    if lic.exists():
        write(lic, read(lic).replace("<year>", year))


def init_main(root, args):
    shutil.rmtree(root / "docs" / "instructor", ignore_errors=True)
    set_license_year(root, args.year)
    for md in [root / "README.md", *sorted((root / "docs").rglob("*.md"))]:
        if not md.exists():
            continue
        text = read(md)
        new = PLACEHOLDER_ROW.sub("", text)
        for p in ORG_PLACEHOLDERS:
            new = new.replace(p, args.org)
        for p in REPO_PLACEHOLDERS:
            new = new.replace(p, args.repo)
        if md.name == "README.md" and md.parent == root:
            new = TEMPLATE_BLOCK.sub("", new)
            new = TITLE_TODO.sub("", new)
            for p in COURSE_PLACEHOLDERS:
                new = new.replace(p, args.course)
        if new != text:
            write(md, new)
            print(f"updated {md.relative_to(root)}")
    # the initialization script is not needed any more (this also turns the workflow into a no-op)
    shutil.rmtree(root / ".github" / "template", ignore_errors=True)


def init_assignments(root, args):
    set_license_year(root, args.year)
    doxyfile = root / "assignments" / "Doxyfile"
    if doxyfile.exists():
        text = read(doxyfile)
        write(doxyfile, re.sub(r"^PROJECT_NAME\s*=.*$", f'PROJECT_NAME           = "{args.course}"', text, flags=re.M))
        print("updated assignments/Doxyfile")
    codeowners = root / ".github" / "CODEOWNERS"
    if codeowners.exists() and args.instructor:
        # only the owner entry: the comment explains the placeholder and stays as it is
        write(codeowners, read(codeowners).replace("@<instructor>", "@" + args.instructor))
        print(f"updated .github/CODEOWNERS (@{args.instructor})")


def leftovers(root):
    found = []
    patterns = ORG_PLACEHOLDERS + REPO_PLACEHOLDERS + COURSE_PLACEHOLDERS + ("<year>", "@<instructor>")
    for f in root.rglob("*"):
        if f.is_file() and ".git" not in f.parts and f.suffix in (".md", "", ".txt"):
            text = read(f)
            found += [f"{f.relative_to(root)}: {p}" for p in patterns if p in text]
    return found


def github(method, url, token, body=None):
    req = urllib.request.Request(url, data=json.dumps(body).encode() if body is not None else None, method=method,
                                 headers={"Authorization": f"Bearer {token}", "Accept": "application/vnd.github+json",
                                          "X-GitHub-Api-Version": "2022-11-28", "User-Agent": "pds-init-course"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read() or "null")


def create_labels(labels_file, repository, token, api="https://api.github.com"):
    """Creates the labels listed in labels_file; existing labels with the same name get the listed color
    and description. Returns (created, updated) names. Problems are warnings: the course stays usable."""
    wanted = json.loads(pathlib.Path(labels_file).read_text(encoding="utf-8"))
    base = f"{api}/repos/{repository}/labels"
    existing = {}
    page = 1
    while True:
        batch = github("GET", f"{base}?per_page=100&page={page}", token)
        existing.update({l["name"].lower(): l for l in batch})
        if len(batch) < 100:
            break
        page += 1
    created, updated = [], []
    for label in wanted:
        body = {"name": label["name"], "color": label["color"].lstrip("#"), "description": label.get("description", "")}
        try:
            have = existing.get(label["name"].lower())
            if not have:
                github("POST", base, token, body)
                created.append(label["name"])
            elif have["color"].lower() != body["color"].lower() or (have.get("description") or "") != body["description"]:
                github("PATCH", f"{base}/{urllib.parse.quote(have['name'])}", token, body)
                updated.append(label["name"])
        except urllib.error.HTTPError as e:
            print(f"::warning::label {label['name']}: GitHub API {e.code} {e.read().decode(errors='replace')[:200]}")
    return created, updated


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "labels":
        if len(sys.argv) != 4 or not os.environ.get("GITHUB_TOKEN"):
            sys.exit("usage: GITHUB_TOKEN=... init_course.py labels <labels.json> <owner/repo>")
        created, updated = create_labels(sys.argv[2], sys.argv[3], os.environ["GITHUB_TOKEN"])
        print(f"labels created: {', '.join(created) or '-'}; updated: {', '.join(updated) or '-'}")
        return 0
    ap = argparse.ArgumentParser()
    ap.add_argument("--branch", choices=["main", "assignments"], required=True)
    ap.add_argument("--path", required=True)
    ap.add_argument("--org", required=True)
    ap.add_argument("--repo", required=True)
    ap.add_argument("--year", required=True)
    ap.add_argument("--course", required=True)
    ap.add_argument("--instructor", default="", help="GitHub username for CODEOWNERS (assignments branch)")
    args = ap.parse_args()
    root = pathlib.Path(args.path)
    (init_main if args.branch == "main" else init_assignments)(root, args)
    rest = leftovers(root)
    for item in rest:
        print(f"::warning::placeholder left: {item}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
