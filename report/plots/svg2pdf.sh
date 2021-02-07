#!/usr/bin/env bash
mkdir -p ./pdfs
find . \( -iname \*.svg \) -print0 | while read -r -d $'\0' file; do
  base="${file##*/}"
  inkscape -D -z "$base" --export-pdf=./pdfs/"$base".pdf
done

