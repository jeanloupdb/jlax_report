#!/usr/bin/env bash
# =============================================================
#  mermaid2img.sh — Convertit un fichier .mmd en PNG haute résolution
#
#  Usage :
#    ./scripts/mermaid2img.sh architecture
#    ./scripts/mermaid2img.sh workflow_n8n
#    ./scripts/mermaid2img.sh figures/diagrams/mon_diag.mmd
#
#  Le fichier PNG est généré dans figures/images/
#  Prérequis : npm install -g @mermaid-js/mermaid-cli
#              (installe la commande `mmdc`)
# =============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAPPORT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$RAPPORT_DIR"

# ── Vérification mmdc ─────────────────────────────────────────
if ! command -v mmdc &>/dev/null; then
  echo "❌  mmdc non trouvé. Installez-le avec :"
  echo "    npm install -g @mermaid-js/mermaid-cli"
  exit 1
fi

# ── Résolution du fichier d'entrée ───────────────────────────
INPUT_ARG="${1:-}"
if [[ -z "$INPUT_ARG" ]]; then
  echo "Usage : $0 <nom_ou_chemin>"
  echo "  Ex  : $0 architecture"
  echo "  Ex  : $0 figures/diagrams/architecture.mmd"
  exit 1
fi

# Accepte : "architecture", "architecture.mmd", "figures/diagrams/architecture.mmd"
if [[ -f "$INPUT_ARG" ]]; then
  INPUT_FILE="$INPUT_ARG"
elif [[ -f "figures/diagrams/${INPUT_ARG%.mmd}.mmd" ]]; then
  INPUT_FILE="figures/diagrams/${INPUT_ARG%.mmd}.mmd"
else
  echo "❌  Fichier introuvable : $INPUT_ARG"
  echo "    Cherché dans : figures/diagrams/${INPUT_ARG%.mmd}.mmd"
  exit 1
fi

BASENAME="$(basename "${INPUT_FILE%.mmd}")"
OUTPUT_FILE="figures/images/${BASENAME}.png"

mkdir -p figures/images

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Source  : $INPUT_FILE"
echo "  Sortie  : $OUTPUT_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Génération PNG haute résolution ──────────────────────────
# -w 2400 : largeur en pixels (haute résolution pour LaTeX)
# --backgroundColor white : fond blanc (pas de transparence)
# -s 2    : scale factor x2
PUPPETEER_CONF=""
if [[ -f "$RAPPORT_DIR/.puppeteer.json" ]]; then
  PUPPETEER_CONF="--puppeteerConfigFile $RAPPORT_DIR/.puppeteer.json"
fi

mmdc \
  -i "$INPUT_FILE" \
  -o "$OUTPUT_FILE" \
  -w 2400 \
  --backgroundColor white \
  -s 2 \
  $PUPPETEER_CONF

echo ""
echo "✅  Image générée : $OUTPUT_FILE"
echo ""
echo "── Commande LaTeX pour intégrer ce diagramme ────────────"
echo "   \\mermaidfig{0.95}{${BASENAME}}{Votre légende ici}"
echo ""
echo "── Ou manuellement ──────────────────────────────────────"
echo "   \\includegraphics[width=0.95\\textwidth]{figures/images/${BASENAME}}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
