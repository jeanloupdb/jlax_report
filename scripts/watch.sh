#!/usr/bin/env bash
# =============================================================
#  watch.sh — Compilation LaTeX + Mermaid en temps réel
#
#  Surveille tous les fichiers .tex et .mmd du projet.
#  À chaque sauvegarde :
#    - si .mmd modifié → génère le PNG correspondant
#    - si .tex modifié → recompile le PDF via Docker
#
#  Usage : ./scripts/watch.sh
#          make watch
#
#  Prérequis : docker, python3 + watchdog (pip install watchdog)
# =============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAPPORT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$RAPPORT_DIR"

# ── Vérifications ─────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
  echo "❌  docker non trouvé"
  exit 1
fi

if ! python3 -c "import watchdog" 2>/dev/null; then
  echo "❌  watchdog Python non installé. Lancez :"
  echo "    pip3 install watchdog --break-system-packages"
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Jlax Expertise — Live watch activé"
echo "  Surveille : *.tex (sections/, tables/, fiches/) et *.mmd"
echo "  Sortie PDF : output/main.pdf + output/fiches/*.pdf"
echo "  Arrêt : Ctrl+C"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Première compilation au démarrage ─────────────────────────
echo "▶  Compilation initiale..."
bash "$SCRIPT_DIR/build.sh" && echo "" || echo "⚠️  Erreur à la compilation initiale"

# ── Script Python watchdog ─────────────────────────────────────
python3 - <<'PYEOF'
import sys
import os
import subprocess
import time
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

RAPPORT_DIR = os.getcwd()
SCRIPTS_DIR = os.path.join(RAPPORT_DIR, "scripts")

# Cooldown pour éviter les doubles déclenchements lors d'un save
last_build = {}
COOLDOWN = 2.0  # secondes

def run_mermaid(mmd_path):
    """Génère le PNG depuis un fichier .mmd"""
    name = Path(mmd_path).stem
    print(f"\n🎨  Mermaid modifié : {Path(mmd_path).name}")
    result = subprocess.run(
        ["bash", os.path.join(SCRIPTS_DIR, "mermaid2img.sh"), name],
        capture_output=True, text=True
    )
    if result.returncode == 0:
        print(f"✅  PNG régénéré → figures/images/{name}.png")
        print("▶  Recompilation LaTeX pour intégrer le nouveau diagramme...")
        run_latex()
    else:
        print(f"❌  Erreur Mermaid :\n{result.stderr}")

def run_latex():
    """Recompile le PDF principal via Docker"""
    print("\n📄  Compilation LaTeX (main)...")
    t0 = time.time()
    result = subprocess.run(
        ["bash", os.path.join(SCRIPTS_DIR, "build.sh")],
        capture_output=True, text=True
    )
    elapsed = time.time() - t0
    if result.returncode == 0:
        print(f"✅  PDF mis à jour en {elapsed:.1f}s → output/main.pdf")
    else:
        # Afficher seulement les lignes d'erreur utiles
        errors = [l for l in result.stdout.split('\n') if 'error' in l.lower() or 'Error' in l]
        if errors:
            print("❌  Erreurs LaTeX :")
            for e in errors[:5]:
                print(f"    {e}")
        else:
            print(f"⚠️  Compilation terminée avec avertissements ({elapsed:.1f}s)")
    print("")

def run_fiche(fiche_name):
    """Recompile une fiche outil spécifique via Docker"""
    print(f"\n📄  Compilation fiche : {fiche_name}...")
    t0 = time.time()
    result = subprocess.run(
        ["bash", os.path.join(SCRIPTS_DIR, "build_fiches.sh"), fiche_name],
        capture_output=True, text=True
    )
    elapsed = time.time() - t0
    if result.returncode == 0:
        print(f"✅  Fiche mise à jour en {elapsed:.1f}s → output/fiches/{fiche_name}.pdf")
    else:
        print(f"❌  Erreur compilation fiche {fiche_name} ({elapsed:.1f}s)")
        if result.stdout:
            print(f"    {result.stdout[-200:]}")
    print("")

class ReportHandler(FileSystemEventHandler):
    def on_modified(self, event):
        if event.is_directory:
            return
        path = event.src_path

        # Cooldown : ignorer les doubles événements
        now = time.time()
        if path in last_build and (now - last_build[path]) < COOLDOWN:
            return
        last_build[path] = now

        # Fichier Mermaid modifié
        if path.endswith('.mmd'):
            run_mermaid(path)

        # Fichier LaTeX modifié
        elif path.endswith('.tex'):
            rel = os.path.relpath(path, RAPPORT_DIR)
            print(f"\n📝  {rel} modifié")

            # Déterminer si c'est une fiche ou le rapport principal
            fiches_dir = os.path.join(RAPPORT_DIR, "fiches")
            if path.startswith(fiches_dir) and not os.path.basename(path).startswith('_'):
                # C'est une fiche outil → recompiler la fiche spécifique
                fiche_name = Path(path).stem
                run_fiche(fiche_name)
            elif not path.startswith(fiches_dir):
                # C'est un fichier du rapport principal
                run_latex()

handler = ReportHandler()
observer = Observer()

# Surveiller récursivement le dossier rapport
observer.schedule(handler, RAPPORT_DIR, recursive=True)
observer.start()

print("👁️  En attente de modifications...")
print("   → Sauvegarder un .tex (sections/, tables/) → recompile main.pdf")
print("   → Sauvegarder un .tex dans fiches/ → recompile la fiche")
print("   → Sauvegarder un .mmd → régénère le PNG + recompile main.pdf\n")

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    observer.stop()
    print("\n\n⏹  Watch arrêté.")

observer.join()
PYEOF
