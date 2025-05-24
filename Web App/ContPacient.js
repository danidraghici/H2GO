const signupForm = document.querySelector('#signup-pacient');
signupForm.addEventListener('submit', async (e) => {
  e.preventDefault();

  const cnp = signupForm['cnp'].value.trim();
  const email = signupForm['email'].value.trim();
  const nume = signupForm['nume'].value.trim();
  const prenume = signupForm['prenume'].value.trim();
  const password = signupForm['password'].value;

  const username = `${nume} ${prenume}`;
  const telefon = signupForm['telefon']?.value || '';
  const rol = 'pacient';
  const id_permisiune = 1;

  if (!cnp || !email || !nume || !prenume || !password) {
    alert('Te rog completează toate câmpurile obligatorii.');
    return;
  }

  try {
    const response = await fetch('http://localhost:3000/api/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ cnp, username, email, telefon, password, rol, id_permisiune })
    });

    const result = await response.json();

    if (result.success) {
      window.location = 'WelcomePacient.html';
    } else {
      alert(result.message || 'Înregistrarea a eșuat.');
    }
  } catch (error) {
    console.error('Eroare:', error);
    alert('A apărut o eroare. Te rog încearcă mai târziu.');
  }
});
