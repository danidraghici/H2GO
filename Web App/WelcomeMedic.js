var logout = document.querySelector('#logout');
onAuthStateChanged(auth, (user) => {
    if (user) {
      // User is signed in, see docs for a list of available properties
      const uid = user.uid;
      var email = user.email;
      console.log(email);
      var userType = user.email.toString().charAt(0);
      // ...
    } else {
      // User is signed out
      // ...
      console.log('Not signed in')
    }
  });
logout.addEventListener('submit', (e) => {
    e.preventDefault();
    console.log('in eventlistener');
    //const auth = getAuth();
    signOut(auth).then(() => {
        document.location = 'index.html';
    }).catch((error) => {
        console.log('Not logged in');
    });
});








