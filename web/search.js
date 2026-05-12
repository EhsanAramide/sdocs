let index;
let documents = [];
let searchData;

async function loadIndex() {

    const response = await fetch("search_index.json");

    searchData = await response.json();
    documents = searchData.pages;

    index = new FlexSearch.Document({
        document: {
            id: "id",
            index: ["title", "content"]
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

    const results = index.search(query, { limit: 10, enrich: true });

    const ids = new Set();

    results.forEach(r =>
        r.result.forEach(x => ids.add(x.id))
    );

    return documents.filter(d => ids.has(d.id));
}

function showSuggestions(items) {

    const box = document.getElementById("suggestions");

    box.innerHTML = "";

    items.slice(0, 5).forEach(item => {

        const div = document.createElement("div");

        div.className = "suggestion";

        div.innerHTML = `<b>${item.title}</b><br><small>${item.doc}</small>`;

        div.onclick = () => window.location = "../" + item.url;

        box.appendChild(div);
    });
}

document.getElementById("search").addEventListener("input", e => {

    const q = e.target.value;

    const results = search(q);

    showSuggestions(results);
});

loadIndex();
