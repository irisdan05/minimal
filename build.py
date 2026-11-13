"""Build the public Formlane site (its.irisdan.xyz) from the private source file.

Run:  python3 build.py
Reads ../designportfolio/backlog-formlane.html, copies only the images/fonts it uses,
and writes index.html plus one folder per page so /about, /lumeno etc. load directly.
"""
import os, re, shutil, urllib.parse

SRC_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'designportfolio')
OUT = os.path.dirname(os.path.abspath(__file__))
DOMAIN = 'https://its.irisdan.xyz'
ROUTES = ['about', 'playground', 'lumeno', 'setdm', 'parpro']

html = open(os.path.join(SRC_DIR, 'backlog-formlane.html'), encoding='utf-8').read()

# absolute base so nested routes (/lumeno/) still find images/ and fonts/
html = html.replace('<head>', '<head>\n<base href="/">', 1)
html = html.replace('https://irisdan.xyz/', DOMAIN + '/')

# copy only the assets the page references
for d in ('images', 'fonts'):
    shutil.rmtree(os.path.join(OUT, d), ignore_errors=True)
refs = set(re.findall(r'''(?:images|fonts)/[^"')\s>]+''', html))
missing = []
for ref in sorted(refs):
    path = urllib.parse.unquote(ref)
    src = os.path.join(SRC_DIR, path)
    if not os.path.isfile(src):
        missing.append(path); continue
    dst = os.path.join(OUT, path)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(src, dst)

def write(rel, text):
    full = os.path.join(OUT, rel)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    open(full, 'w', encoding='utf-8').write(text)

write('index.html', html)
for r in ROUTES:
    write(os.path.join(r, 'index.html'), html)
write('404.html', html)  # unknown paths fall back to the home page

print(f'built {1 + len(ROUTES)} routes, {len(refs) - len(missing)} assets')
if missing:
    print('missing assets:', *missing, sep='\n  ')
