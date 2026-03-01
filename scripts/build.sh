#!/usr/bin/env bash
# =============================================================
#  build.sh — Compilation PDF via Docker (une passe)
#  Utilisé par watch.sh et le Makefile
# =============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAPPORT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$RAPPORT_DIR"
mkdir -p output

docker run --rm \
  -v "$(pwd)":/workdir \
  -w /workdir \
  texlive/texlive:latest \
  latexmk -pdf -quiet -interaction=nonstopmode main.tex
