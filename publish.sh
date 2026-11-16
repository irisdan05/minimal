#!/bin/sh
# Publish the minimal portfolio to BOTH sites in one go:
#   its.irisdan.xyz  (this repo, irisdan05/minimal)
#   irisdan.xyz      (../designportfolio, irisdan05/designportfolio)
# Usage: ./publish.sh "commit message"
set -e
MSG=${1:-"Update minimal portfolio"}
HERE=$(cd "$(dirname "$0")" && pwd)
MAIN="$HERE/../designportfolio"
PAGES="index.html 404.html about/index.html playground/index.html lumeno/index.html setdm/index.html parpro/index.html"

python3 "$HERE/build.py"
python3 "$HERE/build.py" --main

cd "$HERE"
git add -A
git diff --cached --quiet || git commit -q -m "$MSG"
git push -q origin main

cd "$MAIN"
# only the built pages plus any images/fonts the page uses; never .DS_Store or private files
ASSETS=$(python3 -c "import re,urllib.parse;h=open('index.html').read();print(' '.join(sorted(set(urllib.parse.unquote(r) for r in re.findall(r'''(?:images|fonts)/[^\"')\s>]+''',h)))))")
git add $PAGES
for a in $ASSETS; do git add -- "$a"; done
git diff --cached --quiet || git commit -q -m "$MSG"
git push -q origin main
echo "published to its.irisdan.xyz and irisdan.xyz"
