#!/usr/bin/env bash
# =============================================================
#  deploy.sh — Déploiement / mise à jour sur le VPS (YunoHost)
#
#  Le conteneur nginx tourne en local sur 127.0.0.1:8080.
#  YunoHost gère le SSL + le reverse proxy pour reportfiles.jlax.fr
#
#  Étapes initiales (une seule fois, dans l'admin YunoHost) :
#    1. Ajouter le domaine reportfiles.jlax.fr
#    2. Activer Let's Encrypt pour ce domaine
#    3. sudo cp yunohost-nginx.conf /etc/nginx/conf.d/reportfiles.jlax.fr.d/docs.conf
#    4. sudo nginx -t && sudo systemctl reload nginx
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
echo "✅  Conteneur démarré sur 127.0.0.1:8080"
echo "    Portail accessible sur : https://reportfiles.jlax.fr"
echo "    (si YunoHost est configuré — voir yunohost-nginx.conf)"
echo ""
