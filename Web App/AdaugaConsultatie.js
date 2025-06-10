
let tratamentIndex = 0;

function adaugaTratament() {
    const container = document.getElementById("tratamenteList");

    const medicamentDiv = document.createElement("div");
    medicamentDiv.classList.add("tratament-item");
    medicamentDiv.innerHTML = `
        <input type="text" name="denumire_${tratamentIndex}" placeholder="Denumire medicament" required>

        <select name="forma_${tratamentIndex}" required>
            <option value="">Formă...</option>
            <option value="comprimate">Comprimate</option>
            <option value="capsule">Capsule</option>
            <option value="sirop">Sirop</option>
            <option value="injectabil">Injectabil</option>
            <option value="unguent">Unguent</option>
            <option value="spray">Spray</option>
            <option value="supozitor">Supozitor</option>
        </select>

        <input type="text" name="posologie_${tratamentIndex}" placeholder="Ex: 1/8h sau 10ml la nevoie">

        <button type="button" onclick="this.parentElement.remove()">🗑️</button>
    `;
    container.appendChild(medicamentDiv);
    tratamentIndex++;
}

    document.getElementById("consultatieForm").addEventListener("submit", async function(event) {
    event.preventDefault();

    const params = new URLSearchParams(window.location.search);
    const cnp_pacient = params.get('cnp');
    const cnpMedic = localStorage.getItem('cnpMedic');

    if (!cnp_pacient) {
        alert("CNP pacient lipsă în URL!");
        return;
    }

        // 1. Construim lista de tratamente
        const tratamentItems = document.querySelectorAll(".tratament-item");
        let tratament = "";
        for (const item of tratamentItems) {
            const denumire = item.querySelector(`input[name^="denumire_"]`).value.trim();
            const forma = item.querySelector(`select[name^="forma_"]`).value;
            const posologie = item.querySelector(`input[name^="posologie_"]`).value.trim();

            if (!denumire || !forma) {
                alert("Completare lipsă într-un tratament!");
                return;
            }

            tratament += `${denumire}; ${forma}; ${posologie}\n`;
        }


        const consultatie = {
    diagnostic: document.getElementById("diagnostic").value,
    tratament,
    recomandari: document.getElementById("recomandari").value,
    observatii: document.getElementById("motiv").value + "\n" +
        "Simptome: " + document.getElementById("simptome").value + "\n" +
        "Indicații: " + document.getElementById("indicatii").value
    };

    try {
        const response = await fetch(`http://localhost:3000/api/consultatii?cnp_pacient=${cnp_pacient}&cnp_medic=${cnpMedic}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(consultatie)
});

    if (response.ok) {
    alert("Consultația a fost salvată!");
    window.location.href = "Pacienti.html";
} else {
    const error = await response.json();
    alert("Eroare: " + error.message);
}
} catch (err) {
    alert("Eroare de rețea: " + err.message);
}
});
