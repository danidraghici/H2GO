var signinForm = document.querySelector('#login');
signinForm.addEventListener('click', async (e) => {
    e.preventDefault();

    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;

    try {
        const response = await fetch('http://localhost:3000/api/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
        });

        const data = await response.json();

        if (data.success) {
            
            const userType = data.user.userType;
            const cnpMedic = data.user.cnp;
            localStorage.setItem('userType', userType);

            if (userType === 'medic') {
                localStorage.setItem('cnpMedic', cnpMedic);
            }

            // Redirect based on user type
            switch (userType) {
                case 'admin':
                    window.location.href = 'WelcomeAdmin.html';
                    break;
                case 'medic':
                    window.location.href = 'WelcomeMedic.html';
                    break;
                case 'patient':
                    window.location.href = 'WelcomePacient.html';
                    break;
                default:
                    window.location.href = 'WelcomeUser.html';
            }
        } else {
            alert(data.message);
        }
    } catch (error) {
        console.error('Login failed:', error);
        alert('Something went wrong. Try again.');
    }
});

