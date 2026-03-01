#!/usr/bin/env bash
# =============================================================
#  build_all_mermaid.sh — Génère tous les diagrammes Mermaid
#  Parcourt figures/diagrams/*.mmd et génère le PNG correspondant
#
#  Usage : ./scripts/build_all_mermaid.sh
#          make mermaid
# =============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAPPORT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$RAPPORT_DIR"

if ! command -v mmdc &>/dev/null; then
  echo "❌  mmdc non trouvé. Installez avec : npm install -g @mermaid-js/mermaid-cli"
  exit 1
fi

DIAGRAMS=(figures/diagrams/*.mmd)

if [[ ${#DIAGRAMS[@]} -eq 0 || ! -f "${DIAGRAMS[0]}" ]]; then
  echo "ℹ️  Aucun fichier .mmd trouvé dans figures/diagrams/"
  exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Génération de tous les diagrammes Mermaid"
echo "  Trouvé : ${#DIAGRAMS[@]} fichier(s)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p figures/images

ERRORS=0
for MMD_FILE in "${DIAGRAMS[@]}"; do
  BASENAME="$(basename "${MMD_FILE%.mmd}")"
  OUTPUT="figures/images/${BASENAME}.png"

  echo -n "  ▸ $BASENAME ... "

  PUPPETEER_CONF=""
  if [[ -f "$RAPPORT_DIR/.puppeteer.json" ]]; then
    PUPPETEER_CONF="--puppeteerConfigFile $RAPPORT_DIR/.puppeteer.json"
  fi

  if mmdc -i "$MMD_FILE" -o "$OUTPUT" -w 2400 --backgroundColor white -s 2 $PUPPETEER_CONF 2>/dev/null; then
    echo "✅"
  else
    echo "❌ ERREUR"
    ERRORS=$((ERRORS + 1))
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ $ERRORS -eq 0 ]]; then
  echo "  ✅  Tous les diagrammes générés dans figures/images/"
else
  echo "  ⚠️  $ERRORS erreur(s) — vérifiez la syntaxe Mermaid"
  exit 1
fi
