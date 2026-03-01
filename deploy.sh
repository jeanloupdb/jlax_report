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

# Lancer ou redémarrer le conteneur
echo "▶  docker compose up..."
docker compose -f docker-compose.deploy.yml up -d --pull always

echo ""
echo "✅  Portail disponible sur : https://$DOMAIN"
echo ""
