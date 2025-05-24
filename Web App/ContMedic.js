const signupForm = document.querySelector('#signup-medic');

signupForm.addEventListener('submit', async (e) => {
  e.preventDefault();

  const cnp = signupForm['cnp'].value;
  const email = signupForm['email'].value;
  const nume = signupForm['nume'].value;
  const prenume = signupForm['prenume'].value;
  const password = signupForm['password'].value;

  const username = `${nume} ${prenume}`;
  const telefon = signupForm['telefon']?.value || '';
  const rol = 'medic'; 
  const id_permisiune = 1; 


  try {
    const response = await fetch('http://localhost:3000/api/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ cnp, username, email, telefon, password, rol, id_permisiune})
    });

    const result = await response.json();

    if (result.success) {
      window.location = 'WelcomeMedic.html';
    } else {
      alert(result.message || 'Registration failed.');
    }
  } catch (error) {
    console.error('Error:', error);
    alert('An error occurred. Please try again later.');
  }
});
