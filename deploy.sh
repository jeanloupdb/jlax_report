#!/usr/bin/env bash
# =============================================================
#  deploy.sh — Déploiement / mise à jour sur le VPS
#
#  À lancer depuis le répertoire cloné sur le VPS.
#  Usage :
#    bash deploy.sh                         # mise à jour + restart
#    DOMAIN=docs.jlax-expertise.fr bash deploy.sh  # premier déploiement
# =============================================================

set -euo pipefail

DOMAIN="${DOMAIN:-docs.jlax-expertise.fr}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Jlax Expertise — Déploiement portail docs"
echo "  Domaine : $DOMAIN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Pull des dernières modifications
echo "▶  git pull..."
git pull origin main

# Écrire le .env si DOMAIN passé en argument
echo "DOMAIN=$DOMAIN" > .env

# Détecter docker compose V2 ou docker-compose V1
if docker compose version &>/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose &>/dev/null; then
  COMPOSE="docker-compose"
else
  echo "❌  docker compose introuvable (ni V1 ni V2)"
  exit 1
fi

# Lancer ou redémarrer le conteneur
echo "▶  $COMPOSE up..."
$COMPOSE -f docker-compose.deploy.yml up -d --pull always

echo ""
echo "✅  Portail disponible sur : https://$DOMAIN"
echo ""
