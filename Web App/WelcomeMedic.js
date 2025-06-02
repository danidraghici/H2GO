document.querySelector('#logout').addEventListener('submit', (e) => {
    e.preventDefault();
    console.log('in eventlistener');

    // Curăță datele locale
    localStorage.removeItem('userType');

    // Redirecționează
    window.location.href = 'index.html';
});
