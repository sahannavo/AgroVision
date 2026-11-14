#!/usr/bin/env bash
# Render every diagram in docs/report/diagrams/ to a PNG next to its source.
#   *.mmd  -> Mermaid CLI   (npm install -g @mermaid-js/mermaid-cli)
#   *.puml -> PlantUML      (a `plantuml` command on PATH, or PLANTUML_JAR=/path/plantuml.jar with Java,
#                            and Graphviz `dot` installed)
# If Puppeteer cannot find Chrome, set PUPPETEER_EXECUTABLE_PATH to a Chrome/Chromium binary.
# Usage (from anywhere):  bash docs/report/tools/render_diagrams.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
dir="$here/../diagrams"
cfg="$here/puppeteer-config.json"

for src in "$dir"/*.mmd; do
  [ -e "$src" ] || continue
  echo "Mermaid : $(basename "$src")"
  mmdc -i "$src" -o "${src%.mmd}.png" -p "$cfg" -b white -s 2
done

for src in "$dir"/*.puml; do
  [ -e "$src" ] || continue
  echo "PlantUML: $(basename "$src")"
  if command -v plantuml >/dev/null 2>&1; then
    plantuml -tpng -DPLANTUML_LIMIT_SIZE=16384 "$src"
  else
    java -DPLANTUML_LIMIT_SIZE=16384 -jar "${PLANTUML_JAR:?set PLANTUML_JAR or install plantuml}" -tpng "$src"
  fi
done
echo "Done. Commit the sources and the PNGs together."
