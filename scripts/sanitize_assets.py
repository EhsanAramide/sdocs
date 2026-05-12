import hashlib
import os
import re
from pathlib import Path
from urllib.parse import urlparse

import requests
from bs4 import BeautifulSoup

ARCHIVES_DIR = Path("archives")
ASSETS_DIR = ARCHIVES_DIR / "_assets"

ASSETS_DIR.mkdir(parents=True, exist_ok=True)

BLOCKLIST = [
    "google-analytics.com",
    "googletagmanager.com",
    "fonts.googleapis.com",
    "fonts.gstatic.com",
    "doubleclick.net",
    "hotjar.com",
]

ESSENTIAL_PATTERNS = [
    "jquery",
    "bootstrap",
    "highlight",
    "theme",
    "search",
    "navigation",
]

downloaded_cache = {}


def is_blocked(url: str) -> bool:
    return any(domain in url for domain in BLOCKLIST)


def is_essential(url: str) -> bool:
    url = url.lower()
    return any(p in url for p in ESSENTIAL_PATTERNS)


def asset_filename(url: str) -> str:
    parsed = urlparse(url)

    ext = Path(parsed.path).suffix

    if not ext:
        ext = ".bin"

    h = hashlib.sha1(url.encode()).hexdigest()[:16]

    return f"{h}{ext}"


def download_asset(url: str) -> str | None:

    if url in downloaded_cache:
        return downloaded_cache[url]

    try:

        print(f"[download] {url}")

        response = requests.get(url, timeout=20)

        if response.status_code != 200:
            print(f"[skip] bad status {response.status_code}")
            return None

        filename = asset_filename(url)

        out_path = ASSETS_DIR / filename

        with open(out_path, "wb") as f:
            f.write(response.content)

        local_path = f"/archives/_assets/{filename}"

        downloaded_cache[url] = local_path

        return local_path

    except Exception as e:
        print(f"[error] {url}: {e}")
        return None


def process_tag(tag, attr):

    if not tag.has_attr(attr):
        return

    url = tag[attr]

    if not url.startswith("http"):
        return

    # remove garbage
    if is_blocked(url):

        print(f"[remove] {url}")

        tag.decompose()
        return

    # download useful assets
    if is_essential(url):

        local = download_asset(url)

        if local:

            print(f"[rewrite] {url} -> {local}")

            tag[attr] = local


def process_html_file(path: Path):

    try:

        html = path.read_text(encoding="utf-8", errors="ignore")

        soup = BeautifulSoup(html, "lxml")

        for script in soup.find_all("script"):
            process_tag(script, "src")

        for link in soup.find_all("link"):
            process_tag(link, "href")

        path.write_text(str(soup), encoding="utf-8")

        print(f"[ok] {path}")

    except Exception as e:
        print(f"[failed] {path}: {e}")


def main():

    html_files = list(ARCHIVES_DIR.rglob("*.html"))

    print(f"found {len(html_files)} html files")

    for path in html_files:
        process_html_file(path)


if __name__ == "__main__":
    main()
