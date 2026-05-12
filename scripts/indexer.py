import os
import json
from bs4 import BeautifulSoup

ARCHIVES = "archives"
OUT = "web/search_index.json"

pages = []
docs_meta = []

doc_id = 0

for docname in os.listdir(ARCHIVES):

    base = os.path.join(ARCHIVES, docname)

    entrypoint = None

    for root, _, files in os.walk(base):

        for f in files:

            if not f.endswith(".html"):
                continue

            path = os.path.join(root, f)

            rel = os.path.relpath(path, ".")

            # detect entrypoint
            if entrypoint is None and f == "index.html":
                entrypoint = rel

            try:
                with open(path, encoding="utf8") as fp:
                    soup = BeautifulSoup(fp, "lxml")

                title = soup.title.string.strip() if soup.title else f

                text = soup.get_text(" ", strip=True)

                pages.append({
                    "id": doc_id,
                    "title": title,
                    "content": text[:5000],
                    "url": rel,
                    "doc": docname
                })

                doc_id += 1

            except Exception:
                pass

    docs_meta.append({
        "name": docname,
        "entry": entrypoint
    })

data = {
    "docs": docs_meta,
    "pages": pages
}

with open(OUT, "w", encoding="utf8") as f:
    json.dump(data, f)
