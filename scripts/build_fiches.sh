#!/usr/bin/env bash
# =============================================================
#  build_fiches.sh — Compile toutes les fiches outils via Docker
#
#  Usage :
#    bash scripts/build_fiches.sh           # compile toutes les fiches
#    bash scripts/build_fiches.sh n8n       # compile une fiche spécifique
#
#  Sortie : output/fiches/*.pdf
#  Prérequis : docker
# =============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAPPORT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$RAPPORT_DIR/output/fiches"
FICHES_DIR="$RAPPORT_DIR/fiches"

# Liste de toutes les fiches (sans extension)
ALL_FICHES=(
  n8n
  graph_api
  openai_api
  gophish
  wazuh
  crowdsec
  uptime_kuma
  grafana
  vaultwarden
  restic_b2
  secure_score
  flowise
  metabase
  paperless
  odoo
  typebot
  azure_openai
  keycloak
  ollama
)

# Créer le dossier de sortie
mkdir -p "$OUTPUT_DIR"

# Compteurs
SUCCESS=0
FAIL=0

# ── Fonction de compilation d'une fiche ──────────────────────
compile_fiche() {
  local name="$1"
  local tex_file="fiches/${name}.tex"

  # Vérifier que le fichier existe
  if [ ! -f "$RAPPORT_DIR/$tex_file" ]; then
    echo "⚠️   Ignoré : $tex_file introuvable"
    return
  fi

  printf "  %-20s " "$name"

  # Deux passes pour les références correctes
  local log_file="$OUTPUT_DIR/${name}.log"

  local result=0
  docker run --rm \
    -v "$RAPPORT_DIR":/workdir \
    -w /workdir/fiches \
    texlive/texlive:latest \
    bash -c "
      pdflatex -interaction=nonstopmode -output-directory=/workdir/output/fiches ${name}.tex > /dev/null 2>&1 &&
      pdflatex -interaction=nonstopmode -output-directory=/workdir/output/fiches ${name}.tex > /dev/null 2>&1
    " > "$log_file" 2>&1 || result=$?

  if [ $result -eq 0 ] && [ -f "$OUTPUT_DIR/${name}.pdf" ]; then
    echo "✅"
    SUCCESS=$((SUCCESS + 1))
  else
    echo "❌  (voir $OUTPUT_DIR/${name}.log)"
    FAIL=$((FAIL + 1))
  fi
}

# ── Affichage de l'entête ─────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Jlax Expertise — Compilation des fiches outils"
echo "  Sortie : output/fiches/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$RAPPORT_DIR"

# ── Mode : fiche spécifique ou toutes les fiches ─────────────
if [ $# -ge 1 ]; then
  # Compiler uniquement la fiche demandée
  echo "  Mode : fiche unique → $1"
  echo ""
  compile_fiche "$1"
else
  # Compiler toutes les fiches
  echo "  Mode : toutes les fiches (${#ALL_FICHES[@]})"
  echo ""
  for fiche in "${ALL_FICHES[@]}"; do
    compile_fiche "$fiche"
  done
fi

# ── Résumé ────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Résultat : ✅ $SUCCESS réussi(es)  ❌ $FAIL échoué(es)"
if [ $FAIL -eq 0 ]; then
  echo "  Fiches disponibles dans : output/fiches/"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Retourner un code d'erreur si des fiches ont échoué
[ $FAIL -eq 0 ] || exit 1
