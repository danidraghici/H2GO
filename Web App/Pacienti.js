const cnpMedic = localStorage.getItem('cnpMedic');
let cnpPacient = null;
let allPacienti = [];
let currentPage = 1;
const pageSize = 5;

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


function renderPacientRow(pacient) {
    const tr = document.createElement('tr');
    tr.innerHTML = `
        <td>${pacient.CNP}</td>
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
        renderPaginatedList();
    }
}
function renderPaginatedList() {
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
        pacientiToShow.forEach(p => tbody.appendChild(renderPacientRow(p)));
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
    document.getElementById('pulseVal').textContent = masuratori.puls || '-';
    document.getElementById('tempVal').textContent = masuratori.temperatura || '-';
    document.getElementById('humidityVal').textContent = masuratori.umiditate || '-';

    // ECG (exemplu cu librărie Chart.js)
    renderECG(masuratori.ecg || []);

    // Consultatie
    const consultatie = await fetch(`http://localhost:3000/api/ultimaConsultatie/${cnp}`).then(res => res.json());
    document.getElementById('ultimaConsultatieData').textContent = consultatie.data_consultatie || '-';
    document.getElementById('tipConsultatie').textContent = consultatie.tip_consultatie || '-';
    document.getElementById('diagnosticPreliminar').textContent = consultatie.diagnostic_preliminar || '-';
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
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: false
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

loadPacienti();
