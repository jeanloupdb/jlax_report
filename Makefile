# =============================================================
#  Makefile — Jlax Expertise Rapport LaTeX
# =============================================================

.PHONY: all build fiches fiche serve watch clean mermaid mermaid-one install-deps help

# ── Cible par défaut ─────────────────────────────────────────
all: mermaid fiches build

# ── Compilation PDF principal (une passe via Docker) ─────────
build:
	@bash scripts/build.sh
	@echo "✅  PDF généré : output/main.pdf"

# ── Compilation de toutes les fiches outils ──────────────────
fiches:
	@bash scripts/build_fiches.sh

# ── Compilation d'une seule fiche ────────────────────────────
#   Usage : make fiche NAME=n8n
fiche:
	@bash scripts/build_fiches.sh "$(NAME)"

# ── Portail web local ─────────────────────────────────────────
serve:
	@bash scripts/serve.sh

# ── Compilation live (recompile à chaque sauvegarde) ─────────
watch:
	@./scripts/watch.sh

# ── Générer tous les diagrammes Mermaid ──────────────────────
mermaid:
	@./scripts/build_all_mermaid.sh

# ── Générer un seul diagramme Mermaid ────────────────────────
#   Usage : make mermaid-one NAME=architecture
mermaid-one:
	@./scripts/mermaid2img.sh "$(NAME)"

# ── Nettoyage des fichiers temporaires ───────────────────────
clean:
	latexmk -C -quiet main.tex
	@echo "✅  Fichiers temporaires supprimés"

# ── Nettoyage total (inclut PDF) ─────────────────────────────
clean-all: clean
	rm -rf output/
	@echo "✅  Dossier output supprimé"

# ── Installation des dépendances ─────────────────────────────
install-deps:
	@echo "── Docker (nécessaire pour LaTeX) ──"
	@command -v docker >/dev/null 2>&1 && echo "✅  docker OK" || echo "❌  installer docker"
	@echo "── mmdc (Mermaid CLI) ──"
	@command -v mmdc >/dev/null 2>&1 || npm install -g @mermaid-js/mermaid-cli
	@echo "── watchdog Python (pour make watch) ──"
	@python3 -c "import watchdog" 2>/dev/null || pip3 install watchdog --break-system-packages
	@echo "✅  Dépendances installées"

# ── Aide ─────────────────────────────────────────────────────
help:
	@echo ""
	@echo "  Jlax Expertise — Rapport LaTeX"
	@echo ""
	@echo "  Commandes disponibles :"
	@echo ""
	@echo "    make serve          Portail web local → http://localhost:8080"
	@echo "    make build          Compilation PDF principal (une passe)"
	@echo "    make fiches         Compile toutes les fiches outils (19 PDFs)"
	@echo "    make fiche NAME=n8n Compile une fiche spécifique"
	@echo "    make all            Mermaid + fiches + rapport principal"
	@echo "    make watch          Compilation live (recompile au save)"
	@echo "    make mermaid        Génère tous les diagrammes .mmd → PNG"
	@echo "    make mermaid-one    Génère un seul diagramme"
	@echo "                        Ex: make mermaid-one NAME=architecture"
	@echo "    make clean          Supprime les fichiers temporaires LaTeX"
	@echo "    make clean-all      Supprime tout (temp + output/)"
	@echo "    make install-deps   Installe latexmk + mmdc"
	@echo ""
	@echo "  Workflow typique :"
	@echo "    1. make fiches      Générer tous les PDFs fiches"
	@echo "    2. make build       Compiler le rapport principal"
	@echo "    3. make watch       Mode live (surveille fiches/ et sections/)"
	@echo "    4. make fiche NAME=n8n  Recompiler une fiche après modification"
	@echo ""
