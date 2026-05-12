let index;
let documents = [];
let searchData;

async function loadIndex() {

    const response = await fetch("search_index.json");

    searchData = await response.json();
    documents = searchData.pages;

    index = new FlexSearch.Document({
        tokenize: "forward",
        cache: true,
        document: {
            id: "id",
            index: ["title", "content"],
            store: ["title", "url", "doc"]
        }
    });

    documents.forEach(doc => index.add(doc));

    buildSidebar();
}

function buildSidebar() {

    const list = document.getElementById("docs-list");

    searchData.docs.forEach(doc => {

        const li = document.createElement("li");

        const a = document.createElement("a");

        a.href = "../" + doc.entry;

        a.textContent = doc.name;

        li.appendChild(a);

        list.appendChild(li);
    });
}

function search(query) {

    if (!query) return [];

    const results = index.search(query, {
        limit: 10,
        enrich: true
    });
    const items = [];
    const seen = new Set();

    results.forEach(r => {

        r.result.forEach(x => {
            if (!seen.has(x.id)) {
                seen.add(x.id);
                items.push(x.doc);
            }
        });
    });

    return items;
}

function showSuggestions(items) {

    const box = document.getElementById("suggestions");

    box.innerHTML = "";

    items.slice(0, 5).forEach(item => {

        const div = document.createElement("div");

        div.className = "suggestion";

        div.innerHTML = `<b>${item.title}</b><br><small>${item.doc}</small>`;

        div.onclick = () => window.location = "/" + item.url;

        box.appendChild(div);
    });
}

document.getElementById("search").addEventListener("input", e => {

    const q = e.target.value;

    const results = search(q);

    showSuggestions(results);
});

loadIndex();
