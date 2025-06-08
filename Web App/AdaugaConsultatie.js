
    document.getElementById("consultatieForm").addEventListener("submit", async function(event) {
    event.preventDefault();

    const params = new URLSearchParams(window.location.search);
    const cnp_pacient = params.get('cnp');
    const cnpMedic = localStorage.getItem('cnpMedic');

    if (!cnp_pacient) {
        alert("CNP pacient lipsă în URL!");
        return;
    }

    const consultatie = {
    diagnostic: document.getElementById("diagnostic").value,
    tratament: document.getElementById("retete").value + "\n" + document.getElementById("trimiteri").value,
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
