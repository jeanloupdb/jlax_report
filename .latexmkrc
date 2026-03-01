# ── latexmk configuration ────────────────────────────────────
# Compilation : pdflatex
$pdf_mode = 1;

# Répertoire de sortie
$out_dir = 'output';

# Options pdflatex : non-stop + synctex (navigation source/PDF dans les éditeurs)
$pdflatex = 'pdflatex -interaction=nonstopmode -synctex=1 %O %S';

# Extensions à nettoyer avec `latexmk -C`
$clean_ext = 'aux bbl blg idx ind lof lot out toc acn acr alg glg glo gls ist fdb_latexmk fls synctex.gz';

# Nombre max de passes
$max_repeat = 5;
