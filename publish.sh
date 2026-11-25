#!/bin/sh
# Publish the minimal portfolio to irisdan.xyz (../designportfolio, irisdan05/designportfolio).
# its.irisdan.xyz (this repo) now hosts the OLD classic site (tag classic-site) and is
# not touched by this script.
# Usage: ./publish.sh "commit message"
set -e
MSG=${1:-"Update minimal portfolio"}
HERE=$(cd "$(dirname "$0")" && pwd)
MAIN="$HERE/../designportfolio"
PAGES="index.html 404.html about/index.html playground/index.html lumeno/index.html setdm/index.html parpro/index.html"

python3 "$HERE/build.py" --main

cd "$MAIN"
# only the built pages plus any images/fonts the page uses; never .DS_Store or private files
git add $PAGES
python3 - <<'PY'
import re, subprocess, urllib.parse
h = open('index.html').read()
refs = sorted(set(urllib.parse.unquote(r) for r in re.findall(r"""(?:images|fonts)/[^"')\s>]+""", h)))
if refs: subprocess.run(['git', 'add', '--'] + refs, check=True)
PY
git diff --cached --quiet || git commit -q -m "$MSG"
git push -q origin main
echo "published to irisdan.xyz"
