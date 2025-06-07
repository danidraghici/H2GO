const cnpMedic = localStorage.getItem('cnpMedic');

let allPacienti = [];
let currentPage = 1;
const pageSize = 5;

async function getPacienti() {
    const response = await fetch(`http://localhost:3000/api/getPacienti?cnpMedic=${cnpMedic}`);
    return response.json();
}

async function deletePacient(cnp) {
    await fetch(`http://localhost:3000/api/pacienti/${cnp}`, {
        method: 'DELETE'
    });
    loadPacienti();
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
        <td>${pacient.Email}</td>
        <td>${pacient.Status_activ ? 'Activ' : 'Inactiv'}</td>
        <td>
            <button onclick="editPacient('${pacient.CNP}')">Editează</button>
            <button onclick="deletePacient('${pacient.CNP}')">Șterge</button>
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


window.editPacient = function (cnp) {
    fetch(`http://localhost:3000/api/pacienti/${cnp}`)
        .then(res => res.json())
        .then(pacient => {
            document.getElementById('editCNP').value = pacient.CNP;
            document.getElementById('editNume').value = pacient.Nume;
            document.getElementById('editPrenume').value = pacient.Prenume;
            document.getElementById('editEmail').value = pacient.Email;
            document.getElementById('editTelefon').value = pacient.Telefon;
            document.getElementById('editAdresa').value = pacient.Adresa;
            document.getElementById('editStatus').value = pacient.Status_activ ? '1' : '0';
            openModal();
        });
};

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
    document.getElementById('overlay').classList.add('active');
    document.getElementById('editModal').classList.add('active');
}

function closeModal() {
    document.getElementById('overlay').classList.remove('active');
    document.getElementById('editModal').classList.remove('active');
}

window.deletePacient = deletePacient;
loadPacienti();
