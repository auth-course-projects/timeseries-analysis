#!/usr/bin/env bash
mkdir -p ./pdfs
find . \( -iname \*.svg \) -print0 | while read -r -d $'\0' file; do
  base="${file##*/}"
  if [ ! -f "./pdfs/${base}.pdf" ]; then
    echo "New file found ($file)"
    inkscape -D -z "$base" --export-pdf=./pdfs/"$base".pdf &>/dev/null
  fi
done

