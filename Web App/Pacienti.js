const cnpMedic = localStorage.getItem('cnpMedic');
let cnpPacient = null;
let allPacienti = [];
let currentPage = 1;
const pageSize = 8;

let graficChart;

function deschidePopupGrafic() {
    document.getElementById('popupGrafic').style.display = 'block';
}

function inchidePopupGrafic() {
    document.getElementById('popupGrafic').style.display = 'none';
}

async function genereazaGrafic() {
    const perioada = document.getElementById('perioadaSelect').value;
    const cnp = document.getElementById('editCNP').value;

    try {
        const response = await fetch(`http://localhost:3000/api/date-monitorizare?cnp=${cnp}&perioada=${perioada}`);
        const data = await response.json();

        if (!Array.isArray(data) || data.length === 0) {
            alert('Nu există date pentru perioada selectată.');
            return;
        }

        const labels = data.map(d =>
            new Date(d.data_masurare).toLocaleString('ro-RO', {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            })
        );

        const puls = data.map(d => d.masurare_puls);
        const temperatura = data.map(d => d.masurare_temperatura);
        const umiditate = data.map(d => d.masurare_umiditate);

        if (graficChart) graficChart.destroy();

        const ctx = document.getElementById('graficDate').getContext('2d');
        graficChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels,
                datasets: [
                    { label: 'Puls (bpm)', data: puls, borderColor: 'blue', fill: false },
                    { label: 'Temperatură (°C)', data: temperatura, borderColor: 'red', fill: false },
                    { label: 'Umiditate (%)', data: umiditate, borderColor: 'green', fill: false }
                ]
            }
        });

        graficChart.customData = { labels, puls, temperatura, umiditate };
    } catch (err) {
        console.error('Eroare fetch:', err);
        alert('Eroare la încărcarea datelor monitorizate.');
    }
}


function descarcaExcel() {
    if (!graficChart || !graficChart.customData) {
        alert("Generează graficul mai întâi!");
        return;
    }

    const { labels, puls, temperatura, umiditate } = graficChart.customData;

    const rows = [["Zi", "Puls (bpm)", "Temperatură (°C)", "Umiditate (%)"]];
    for (let i = 0; i < labels.length; i++) {
        rows.push([labels[i], puls[i], temperatura[i], umiditate[i]]);
    }

    const wb = XLSX.utils.book_new();
    const ws = XLSX.utils.aoa_to_sheet(rows);
    XLSX.utils.book_append_sheet(wb, ws, "Monitorizare");

    XLSX.writeFile(wb, "GraficDateMonitorizare.xlsx");
}



let ecgChartInstance = null;

document.querySelector('button[type="submit"]').addEventListener('click', async () => {
    const status = document.getElementById("editStatus").value;
    const rows = document.querySelectorAll('#tabelPraguri tbody tr');

    const praguri = [];

    rows.forEach(row => {
        const id = row.querySelector('input[id^="minPuls"]').id.split('-')[1];

        praguri.push({
            limita_minima_puls: parseFloat(document.getElementById(`minPuls-${id}`).value),
            limita_maxima_puls: parseFloat(document.getElementById(`maxPuls-${id}`).value),
            limita_minima_temperatura: parseFloat(document.getElementById(`minTemp-${id}`).value),
            limita_maxima_temperatura: parseFloat(document.getElementById(`maxTemp-${id}`).value),
            limita_minima_umiditate: parseFloat(document.getElementById(`minUmi-${id}`).value),
            limita_maxima_umiditate: parseFloat(document.getElementById(`maxUmi-${id}`).value),
            limita_minima_ekg: parseFloat(document.getElementById(`minEKG-${id}`).value),
            limita_maxima_ekg: parseFloat(document.getElementById(`maxEKG-${id}`).value),
        });
    });

    const response = await fetch('http://localhost:3000/api/update-praguri', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            status,
            praguri,
            cnpPacient,
            cnpMedic
        })
    });

    const result = await response.json();
    if (result.success) {
        alert("Modificările au fost salvate!");
    } else {
        alert("Eroare la salvare.");
    }
});


async function getPacienti() {
    const response = await fetch(`http://localhost:3000/api/getPacienti?cnpMedic=${cnpMedic}`);
    return response.json();
}


async function renderPacientRow(pacient) {
    const tr = document.createElement('tr');
    const masuratoriResp = await fetch(`http://localhost:3000/api/masuratori/${pacient.CNP}`);
    const masuratori = await masuratoriResp.json();

    const alertaSemn = masuratori.alerta ? '⚠️ ' : ''; // Semn de alertă
    tr.innerHTML = `
        <td>${alertaSemn}${pacient.CNP}</td>
        <td>${pacient.Nume}</td>
        <td>${pacient.Prenume}</td>
        <td>${pacient.Sex}</td>
        <td>${new Date(pacient.Data_nasterii).toLocaleDateString()}</td>
        <td>${pacient.Adresa}</td>
        <td>${pacient.Telefon}</td>
        <td>${pacient.Email}
        <td>${pacient.ultima_programare ? new Date(pacient.ultima_programare).toLocaleDateString() : '–'}</td>
        <td>${pacient.ultim_tratament || '–'}</td>
        <td>${pacient.Status_activ ? 'Activ' : 'Inactiv'}</td>
        <td>
            <button onclick="editPacient('${pacient.CNP}')">Vizualizeaza</button>
        </td>
    `;
    return tr;
}

async function loadPacienti() {
    const { success, pacienti } = await getPacienti();
    if (success) {
        allPacienti = pacienti;
        await renderPaginatedList();
    }
}
async function renderPaginatedList() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    const filtered = allPacienti.filter(p =>
        p.Nume.toLowerCase().includes(searchTerm)
    );

    const totalPages = Math.ceil(filtered.length / pageSize);
    if (currentPage > totalPages) currentPage = totalPages || 1;

    const start = (currentPage - 1) * pageSize;
    const end = start + pageSize;
    const pacientiToShow = filtered.slice(start, end);

    const tbody = document.getElementById('patientsList');
    tbody.innerHTML = '';

    if (pacientiToShow.length === 0) {
        tbody.innerHTML = '<tr><td colspan="10">Niciun pacient găsit</td></tr>';
    } else {
        const rowPromises = pacientiToShow.map(p => renderPacientRow(p));
        const rows = await Promise.all(rowPromises);

        rows.forEach(row => tbody.appendChild(row));
    }

    document.getElementById('currentPage').textContent = `Pagina ${currentPage}`;
    document.getElementById('prevPage').disabled = currentPage === 1;
    document.getElementById('nextPage').disabled = currentPage === totalPages || totalPages === 0;
}

document.getElementById('searchInput').addEventListener('input', () => {
    currentPage = 1;
    renderPaginatedList();
});

document.getElementById('prevPage').addEventListener('click', () => {
    if (currentPage > 1) {
        currentPage--;
        renderPaginatedList();
    }
});

document.getElementById('nextPage').addEventListener('click', () => {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    const totalFiltered = allPacienti.filter(p =>
        p.Nume.toLowerCase().includes(searchTerm)
    );
    const totalPages = Math.ceil(totalFiltered.length / pageSize);
    if (currentPage < totalPages) {
        currentPage++;
        renderPaginatedList();
    }
});


window.editPacient = async function (cnp) {
    cnpPacient = cnp;
    const pacient = await fetch(`http://localhost:3000/api/pacienti/${cnp}`).then(res => res.json());
    document.getElementById('editCNP').value = pacient.CNP;
    document.getElementById('editNume').value = pacient.Nume;
    document.getElementById('editPrenume').value = pacient.Prenume;
    document.getElementById('editEmail').value = pacient.Email;
    document.getElementById('editTelefon').value = pacient.Telefon;
    document.getElementById('editAdresa').value = pacient.Adresa;
    document.getElementById('editStatus').value = pacient.Status_activ ? '1' : '0';

    document.getElementById('editDataNasterii').value = new Date(pacient.Data_nasterii).toISOString().split('T')[0];
    document.getElementById('editSex').value = pacient.Sex;

    // Praguri

   await fetch(`http://localhost:3000/api/praguri/${cnp}`)
        .then(res => res.json())
        .then(data => {
            const tbody = document.querySelector('#tabelPraguri tbody');
            tbody.innerHTML = '';

            data.forEach(prag => {
                const poateEdita = prag.cnp_doctor === cnpMedic || prag.cnp_doctor == null;
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>
                    <input type="number" value="${prag.limita_minima_puls}" id="minPuls-${prag.id}" ${!poateEdita ? 'disabled' : ''}>
                    -
                        <input type="number" value="${prag.limita_maxima_puls}" id="maxPuls-${prag.id}" ${!poateEdita ? 'disabled' : ''}>
                        </td>
                <td>
                    <input type="number" value="${prag.limita_minima_temperatura}" id="minTemp-${prag.id}" ${!poateEdita ? 'disabled' : ''}>
                        -
                        <input type="number" value="${prag.limita_maxima_temperatura}" id="maxTemp-${prag.id}" ${!poateEdita ? 'disabled' : ''}>
                </td>
                 <td>
                    <input type="number" value="${prag.limita_minima_umiditate}" id="minUmi-${prag.id}" ${!poateEdita ? 'disabled' : ''}>
                        -
                        <input type="number" value="${prag.limita_maxima_umiditate}" id="maxUmi-${prag.id}" ${!poateEdita ? 'disabled' : ''}>
                </td>
                <td>
                    <input type="number" value="${prag.limita_minima_ekg}" id="minEKG-${prag.id}" ${!poateEdita ? 'disabled' : ''}>
                        -
                        <input type="number" value="${prag.limita_maxima_ekg}" id="maxEKG-${prag.id}" ${!poateEdita ? 'disabled' : ''}>
                </td>
            `;
                tbody.appendChild(row);
            });
        });
    // Masuratori
    const masuratori = await fetch(`http://localhost:3000/api/masuratori/${cnp}`).then(res => res.json());
    document.getElementById('clasificareBoala').textContent = masuratori.clasificare || '-';
    document.getElementById('pulseVal').textContent = masuratori.puls || '-';
    document.getElementById('tempVal').textContent = masuratori.temperatura || '-';
    document.getElementById('humidityVal').textContent = masuratori.umiditate || '-';

    // ECG (exemplu cu librărie Chart.js)
    renderECG(masuratori.ekg || []);

    const headings = document.querySelectorAll('.section h4');
    let section = null;

    headings.forEach(h => {
        if (h.textContent.includes("Date monitorizate de senzori")) {
            section = h.parentNode;
        }
    });

    let alertaContainer = document.getElementById('alertaContainer');
    if (!alertaContainer) {
        alertaContainer = document.createElement('div');
        alertaContainer.id = 'alertaContainer';
        section.appendChild(alertaContainer);
    }

    alertaContainer.innerHTML = masuratori.alerta ? `
        <div style="background-color: #ffd6d6; border-left: 5px solid red; padding: 10px; margin-top: 10px;">
            <strong>⚠️ Alertă:</strong><br>
            <strong>Mesaj:</strong> ${masuratori.alerta.mesaj}<br>
            <strong>Severitate:</strong> ${masuratori.alerta.severitate}<br>
            <strong>Data:</strong> ${masuratori.alerta.data_generare}
        </div>
    ` : '';
    // Consultatie
    const consultatie = await fetch(`http://localhost:3000/api/ultimaConsultatie/${cnp}`).then(res => res.json());
    document.getElementById('ultimaConsultatieData').textContent = consultatie.data_consultatie || '-';
    document.getElementById('diagnosticPreliminar').textContent = consultatie.diagnostic || '-';
    document.getElementById('observatii').textContent = consultatie.observatii || '-';
    document.getElementById('recomandari').textContent = consultatie.recomandari || '-';

    // Tratament
    const tratament = await fetch(`http://localhost:3000/api/ultimulTratament/${cnp}`).then(res => res.json());
    document.getElementById('medicament').textContent = tratament.denumire_medicament || '-';
    document.getElementById('formaFarmaceutica').textContent = tratament.forma_farmaceutica || '-';
    document.getElementById('posologie').textContent = tratament.posologie || '-';
    document.getElementById('ultimaPrescriere').textContent = tratament.data_ultima_prescriere || '-';

    openModal();
}

function renderECG(data) {
    const ctx = document.getElementById('ecgChart').getContext('2d');

    // 🧹 Distruge chart-ul vechi, dacă există
    if (ecgChartInstance) {
        ecgChartInstance.destroy();
    }

    ecgChartInstance = new Chart(ctx, {
        type: 'line',
        data: {
            labels: data.map((_, i) => i + 1),
            datasets: [{
                label: 'ECG',
                data: data,
                borderColor: 'red',
                borderWidth: 2,
                fill: false
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false, // permite controlul prin CSS
            scales: {
                x: {
                    ticks: {
                        autoSkip: true,
                        maxTicksLimit: 20 // limitează cât de des sunt afișate valorile
                    }
                }
            }
        }
    });
}

document.getElementById('editForm').addEventListener('submit', async function (e) {
    e.preventDefault();
    const cnp = document.getElementById('editCNP').value;
    const updatedData = {
        nume: document.getElementById('editNume').value,
        prenume: document.getElementById('editPrenume').value,
        email: document.getElementById('editEmail').value,
        telefon: document.getElementById('editTelefon').value,
        adresa: document.getElementById('editAdresa').value,
        status_activ: document.getElementById('editStatus').value === '1'
    };

    await fetch(`http://localhost:3000/api/pacienti/${cnp}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updatedData)
    });

    closeModal();
    loadPacienti();
});

function openModal() {
    document.getElementById('editModal').classList.add('active');
}

function closeModal() {
    document.getElementById('editModal').classList.remove('active');
}

function  adaugaConsultatie() {
    let pacient = document.getElementById('editCNP').value;
    window.location.href = `AdaugaConsultatie.html?cnp=${pacient}`;
}

async function partajeazaFHIR() {
    const pacientId = document.getElementById('editCNP').value;
    const response = await fetch(`http://localhost:3000/api/pacienti/${pacientId}/share-fhir`, {
        method: 'POST'
    });

    const data = await response.json();
    if (response.ok) {
        alert("Partajare reușită: " + data.message);
    } else {
        alert("Eroare la partajare: " + data.message);
    }
}
loadPacienti();
