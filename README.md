# sdocs — Offline Documentation Search Engine

sdocs is a lightweight system for building a **fully offline searchable archive of documentation websites**.  
It downloads documentation pages, indexes them locally, and provides a fast browser-based search interface that works **without any internet connection**.

The project is designed for developers who deal with unstable internet connections, restricted networks, or simply want instant local access to documentation.


### ✨ Important Note

**This project is vibe coded.**  
The architecture, scripts, and implementation were generated collaboratively with **ChatGPT** through iterative design and refinement.

The goal was to build a **simple, practical, reproducible offline documentation system** with minimal dependencies and transparent tooling.


## What sdocs Does

sdocs automates a small pipeline:

1. Download documentation websites
2. Store them locally
3. Extract searchable content
4. Build a search index
5. Provide a browser-based offline search UI

Everything runs locally. No external services, no cloud indexing, no tracking.


## Requirements

To use sdocs locally you only need a few common tools installed, most of them are installed on GNU/Linux distros.

Make sure dependencies are installed:

*Archlinux*
> `sudo pacman -S wget make python3 git`

## Preparation

- **Clone the repository:**

```sh
git clone https://github.com/EhsanAramide/sdocs
cd sdocs
```


- **Adding Documentation Sources:**

Edit the file:

```
docs.list
```

Each line should contain directory name and documentation URL:

Example:

```
python3 https://docs.python.org/3/
fastapi https://fastapi.tiangolo.com/
redis https://redis.io/docs/
```

sdocs will download and archive each site.


## Usage

The workflow is controlled through the Makefile.

### 1. Fetch documentation

```sh
make fetch
```

This downloads all documentation sources listed in `docs.list`.


### 2. Build the search index

```sh
make index
```

This extracts text and generates:

```txt
web/search_index.json
```


### 3. Run the local search engine

```sh
make serve
```

Then open your browser:

```
http://localhost:8000
```

You now have a **fully offline documentation search engine**.


## Offline Search

The web interface uses **FlexSearch** running entirely in the browser.

Features:

- instant search
- zero network requests
- local JSON index
- fast indexing
- no backend required

Everything works even on **air‑gapped machines**.


## Project Structure

```
sdocs/
│
├─ archives/          # raw files of documentations
├─ archives/          # compressed files of documentations
├─ scripts/           # helper scripts
│   ├─ fetch.sh
│   └─ indexer.py
│
├─ web/               # search interface
│   ├─ index.html
│   ├─ styles.css
│   ├─ search.js
│   ├─ search_index.json
│   └─ lib/
│       └─ flexsearch.bundle.min.js
│
├─ config/
│   └─   docs.list          # list of documentation sources
├─ Makefile
└─ README.md
```


## Philosophy

sdocs follows a few simple principles:

- **offline first**
- **minimal dependencies**
- **transparent tooling**
- **simple architecture**
- **developer friendly**

No frameworks. No heavy infrastructure. Just simple tools working together.


## Possible Future Improvements

Some ideas for future versions:

- better ranking for documentation search
- result highlighting
- keyboard navigation
- automatic deduplication
- compressed documentation archives
- improved indexing pipeline


## Final Words

sdocs was created as a practical tool for developers who want **fast, reliable access to documentation without depending on the internet**.

If you find it useful, feel free to extend it, fork it, or adapt it to your own workflows.
