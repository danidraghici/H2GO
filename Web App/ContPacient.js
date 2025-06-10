const signupForm = document.querySelector('#signup-pacient');
signupForm.addEventListener('submit', async (e) => {
  e.preventDefault();

  const cnp = signupForm['cnp'].value.trim();
  const email = signupForm['email'].value.trim();
  const nume = signupForm['nume'].value.trim();
  const prenume = signupForm['prenume'].value.trim();
  const password = signupForm['password'].value;

  const telefon = signupForm['telefon']?.value || '';
  const rol = 'pacient';
  const cnpMedic = localStorage.getItem('cnpMedic');

  const sex = signupForm['sex'].value.trim();
  const data_nasterii = signupForm['data_nasterii'].value;
  const adresa = signupForm['adresa'].value.trim();


  if (!cnp || !email || !nume || !prenume || !password) {
    alert('Te rog completează toate câmpurile obligatorii.');
    return;
  }

  try {
    const response = await fetch('http://localhost:3000/api/addPacienti', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ cnp, nume, prenume, sex, data_nasterii, adresa, telefon, email, password, rol, cnpMedic })
    });

    const result = await response.json();

    if (result.success) {
      window.location.href = 'Pacienti.html';
    } else {
      alert(result.message || 'Înregistrarea a eșuat.');
    }
  } catch (error) {
    console.error('Eroare:', error);
    alert('A apărut o eroare. Te rog încearcă mai târziu.');
  }
});
