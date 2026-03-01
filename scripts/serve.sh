#!/usr/bin/env bash
# =============================================================
#  serve.sh — Serveur local pour le portail de documents
#
#  Lance un serveur HTTP sur http://localhost:8080
#  et ouvre le navigateur automatiquement.
#
#  Usage : bash scripts/serve.sh
#          make serve
# =============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAPPORT_DIR="$(dirname "$SCRIPT_DIR")"
PORT=8080
URL="http://localhost:$PORT"

cd "$RAPPORT_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Jlax Expertise — Portail Documents"
echo "  URL  : $URL"
echo "  Root : $RAPPORT_DIR"
echo "  Arrêt : Ctrl+C"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Ouvrir le navigateur après 1 seconde
(sleep 1 && (
  if command -v xdg-open &>/dev/null; then xdg-open "$URL"
  elif command -v open &>/dev/null; then open "$URL"
  fi
)) &

# Démarrer le serveur (Python en priorité, sinon Node)
if command -v python3 &>/dev/null; then
  echo "▶  Serveur Python (python3 -m http.server $PORT)..."
  python3 -m http.server "$PORT"
elif command -v npx &>/dev/null; then
  echo "▶  Serveur Node (npx serve -p $PORT)..."
  npx serve -p "$PORT" .
else
  echo "❌  Aucun serveur disponible."
  echo "    Installez Python 3 ou Node.js, ou ouvrez index.html directement."
  exit 1
fi
