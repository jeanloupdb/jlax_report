#!/usr/bin/env bash
# =============================================================
#  deploy.sh — Déploiement / mise à jour sur le VPS
#
#  Prérequis : Traefik tourne sur le réseau externe "traefik_proxy"
#              avec un certresolver "letsencrypt" configuré.
#
#  Usage :
#    bash deploy.sh
# =============================================================

set -euo pipefail

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Jlax Expertise — Déploiement portail docs"
echo "  Domaine : https://reportfiles.jlax.fr"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "▶  git pull..."
git pull origin main

# Détecter docker compose V2 ou docker-compose V1
if docker compose version &>/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose &>/dev/null; then
  COMPOSE="docker-compose"
else
  echo "❌  docker compose introuvable"
  exit 1
fi

echo "▶  $COMPOSE up..."
$COMPOSE -f docker-compose.deploy.yml up -d --pull always

echo ""
echo "✅  Portail disponible sur : https://reportfiles.jlax.fr"
echo ""
