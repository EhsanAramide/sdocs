import os
import json
from bs4 import BeautifulSoup

ARCHIVES = "archives"
OUT = "web/search_index.json"

docs = []
doc_id = 0

for docname in os.listdir(ARCHIVES):

    base = os.path.join(ARCHIVES, docname)

    for root, _, files in os.walk(base):

        for f in files:

            if not f.endswith(".html"):
                continue

            path = os.path.join(root, f)

            try:
                with open(path, encoding="utf8") as fp:
                    soup = BeautifulSoup(fp, "html.parser")

                title = soup.title.string if soup.title else f

                text = soup.get_text(" ", strip=True)

                rel = os.path.relpath(path, ".")

                docs.append({
                    "id": doc_id,
                    "title": title,
                    "content": text[:5000],
                    "url": rel,
                    "doc": docname
                })

                doc_id += 1

            except:
                pass

with open(OUT, "w", encoding="utf8") as f:
    json.dump(docs, f)
