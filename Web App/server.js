const express = require('express');
const cors = require('cors');
const sql = require('mssql');
const bcrypt = require('bcrypt');
const dotenv = require('dotenv');

const { v4: uuidv4 } = require('uuid'); 

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const config = {
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    server: process.env.DB_SERVER,
    database: process.env.DB_NAME,
    options: {
        encrypt: true,
        trustServerCertificate: false
    }
};


app.post('/api/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        await sql.connect(config);
        const result = await sql.query`SELECT * FROM Utilizatori WHERE Email = ${email}`;

        if (result.recordset.length === 0) {
            return res.status(401).json({ success: false, message: 'Invalid credentials' });
        }

        const user = result.recordset[0];
        const passwordMatch = await bcrypt.compare(password, user.parola_hash);

        if (!passwordMatch) {
            return res.status(401).json({ success: false, message: 'Invalid credentials' });
        }

        // const token = jwt.sign({ id: user.ID, email: user.Email }, JWT_SECRET, { expiresIn: '1h' });

        res.status(200).json({ success: true, user: { id: user.ID, email: user.Email, userType: user.rol, cnp: user.CNP } });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Server error' });
    }
});


app.post('/api/register', async (req, res) => {
  const { cnp, username, email, telefon, password, rol, id_permisiune } = req.body;

  try {
    await sql.connect(config);

    // Check if user already exists
    const existingUser = await sql.query`SELECT * FROM utilizatori WHERE email = ${email}`;
    if (existingUser.recordset.length > 0) {
      return res.status(400).json({ success: false, message: 'User already exists' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Generate GUID for id
    const id = uuidv4();

    // Dates
    const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD

    await sql.query`
  INSERT INTO utilizatori (id, username, parola_hash, email, telefon, rol, id_permisiune, data_crearii, ultima_logare, CNP)
  VALUES (${id}, ${username}, ${hashedPassword}, ${email}, ${telefon}, ${rol}, ${id_permisiune}, ${today}, ${today}, ${cnp})
`;

    res.status(201).json({ success: true, message: 'User registered successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Registration failed' });
  }
});

app.get('/api/getPacienti', async (req, res) => {
    const cnpMedic = req.query.cnpMedic;

    try {
        await sql.connect(config);
        const result = await sql.query(`
            SELECT 
                p.*, 
                (SELECT TOP 1 data_programare 
                 FROM programari 
                 WHERE cnp_pacient = p.CNP 
                 ORDER BY data_programare DESC) AS ultima_programare,
                (SELECT TOP 1 denumire_medicament 
                 FROM medicatie_curenta 
                 WHERE cnp_pacient = p.CNP 
                 ORDER BY data_ultima_prescriere DESC) AS ultim_tratament
            FROM Pacienti p
            WHERE cnp_medic = '${cnpMedic}' and Status_activ = '1'
        `);

        res.json({ success: true, pacienti: result.recordset });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Eroare la obținerea pacienților' });
    }
});

// adauga pacient
app.post('/api/addPacienti', async (req, res) => {
    const {
        cnp,
        nume,
        prenume,
        sex,
        data_nasterii,
        adresa,
        telefon,
        email,
        password,
        cnpMedic
    } = req.body;

    if (!cnp || !nume || !prenume || !sex || !data_nasterii || !adresa || !telefon || !email || !password || !cnpMedic) {
        return res.status(400).json({ success: false, message: 'Toate câmpurile sunt obligatorii.' });
    }

    try {
        await sql.connect(config);

        // Verifică dacă pacientul există deja (după CNP sau email) în tabela `pacienti`
        const existing = await sql.query`
            SELECT * FROM pacienti WHERE CNP = ${cnp}
        `;

        if (existing.recordset.length > 0) {
            return res.status(400).json({ success: false, message: 'Pacientul există deja' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);


        await sql.query`
            INSERT INTO pacienti (
                CNP, Nume, Prenume, Sex, Data_nasterii, Adresa, Telefon, Email, Status_activ, CNP_medic
            ) VALUES (
                ${cnp}, ${nume}, ${prenume}, ${sex}, ${data_nasterii}, ${adresa},
                ${telefon}, ${email}, ${true}, ${cnpMedic}
            )
        `;

        res.status(201).json({ success: true });
    } catch (err) {
        console.error('Eroare la adăugarea pacientului:', err);
        res.status(500).json({ success: false, message: 'Eroare la adăugarea pacientului' });
    }
});

app.get('/api/pacienti/:cnp', async (req, res) => {
    const cnp = req.params.cnp;
    try {
        await sql.connect(config);
        const result = await sql.query`SELECT * FROM Pacienti WHERE CNP = ${cnp}`;
        if (result.recordset.length > 0) {
            res.json(result.recordset[0]);
        } else {
            res.status(404).json({ message: 'Pacientul nu a fost găsit' });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Eroare la obținerea pacientului' });
    }
});

app.put('/api/pacienti/:cnp', async (req, res) => {
    const cnp = req.params.cnp;
    const { nume, prenume, email, telefon, adresa, status_activ } = req.body;
    try {
        await sql.connect(config);
        await sql.query`
            UPDATE Pacienti SET 
                Nume = ${nume}, 
                Prenume = ${prenume},
                Email = ${email},
                Telefon = ${telefon},
                Adresa = ${adresa},
                Status_activ = ${status_activ}
            WHERE CNP = ${cnp}
        `;
        res.json({ message: 'Pacient actualizat cu succes' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Eroare la actualizarea pacientului' });
    }
});

app.get('/api/masuratori/:cnp', async (req, res) => {
    const { cnp } = req.params;
    let masuratori;
    try {
        const request = new sql.Request();

        // Obține ultima înregistrare de măsurători pentru pacient
        const result = await request.query(`
            SELECT TOP 1
                masurare_ekg,
                masurare_puls,
                masurare_umiditate,
                masurare_temperatura,
                data_masurare
            FROM masuratori
            WHERE cnp_pacient = '${cnp}'
            ORDER BY data_masurare DESC
        `);

        // Obține ultimele 100 valori EKG pentru grafic
        const ecgResult = await request.query(`
            SELECT TOP 100 masurare_ekg
            FROM masuratori
            WHERE cnp_pacient = '${cnp}'
            ORDER BY data_masurare DESC
        `);

        if (result.recordset.length === 0) {
            masuratori = {
                ekg: 0, // pentru grafic, ordonat crescător după timp
                puls: parseFloat(0),
                umiditate: parseFloat(0),
                temperatura: parseFloat(0),
                data_masurare: 0
            };
        }
    else {
            const latest = result.recordset[0];

            masuratori = {
                ekg: ecgResult.recordset.map(r => parseFloat(r.masurare_ekg)).reverse(), // pentru grafic, ordonat crescător după timp
                puls: parseFloat(latest.masurare_puls),
                umiditate: parseFloat(latest.masurare_umiditate),
                temperatura: parseFloat(latest.masurare_temperatura),
                data_masurare: latest.data_masurare
            };
        }
        res.json(masuratori);
    } catch (err) {
        console.error(err);
        res.status(500).send('Eroare la interogarea masurărilor');
    }
});


app.get('/api/ultimaConsultatie/:cnp', async (req, res) => {
    const { cnp } = req.params;

    try {
        const request = new sql.Request();

        const result = await request.query(`
            SELECT TOP 1 
                c.id_consultatie,
                c.id_programare,
                c.diagnostic,
                c.tratament,
                c.recomandari,
                c.data_consultatie,
                c.observatii,
                p.cnp_doctor,
                p.data_programare,
                p.status,
                p.comentarii
            FROM consultatii c
            INNER JOIN programari p ON c.id_programare = p.id
            WHERE p.cnp_pacient = '${cnp}'
            ORDER BY c.data_consultatie DESC
        `);

        if (result.recordset.length === 0) {
            return res.status(200).json({ message: 'Nu există înregistrări' });
        }

        res.json(result.recordset[0]);
    } catch (err) {
        console.error(err);
        res.status(500).send('Eroare la interogarea consultației');
    }
});


app.get('/api/ultimulTratament/:cnp', async (req, res) => {
    const { cnp } = req.params;

    try {
        const request = new sql.Request();
        request.input('cnp', sql.Char(13), cnp);

        const result = await request.query(`
            SELECT TOP 1 
                denumire_medicament, 
                forma_farmaceutica, 
                posologie, 
                data_ultima_prescriere
            FROM medicatie_curenta
            WHERE cnp_pacient = @cnp
            ORDER BY data_ultima_prescriere DESC
        `);

        if (result.recordset.length === 0) {
            return res.status(200).json({ message: 'Nu există înregistrări' });
        }

        res.json(result.recordset[0]);
    } catch (err) {
        console.error("Eroare SQL:", err);
        res.status(500).json({ error: err.message });
    }
});

// GET toate pragurile pentru un pacient (toți medicii)
app.get('/api/praguri/:cnp', async (req, res) => {
    const { cnp } = req.params;

    const request = new sql.Request();
    request.input('cnp', sql.Char(13), cnp);

    try {
        const result = await request.query(`
                SELECT id, cnp_medic,
                       limita_minima_puls, limita_maxima_puls,
                       limita_minima_temperatura, limita_maxima_temperatura,
                       limita_minima_umiditate, limita_maxima_umiditate,
                       limita_minima_ekg, limita_maxima_ekg
                FROM praguri_masuratori 
                WHERE cnp_pacient = @cnp
            `);

        if (result.recordset.length === 0) {
            return res.status(200).json([{
                id: null,
                cnp_medic: null,
                limita_minima_puls: 0,
                limita_maxima_puls: 0,
                limita_minima_temperatura: 0,
                limita_maxima_temperatura: 0,
                limita_minima_umiditate: 0,
                limita_maxima_umiditate: 0,
                limita_minima_ekg: 0,
                limita_maxima_ekg: 0
            }]);
        }

        res.json(result.recordset);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Eroare la preluarea pragurilor.' });
    }
});

app.post('/api/update-praguri', async (req, res) => {
    const { status, praguri, cnpPacient, cnpMedic } = req.body;

    const sql = require('mssql');
    const pool = await sql.connect(config);
    const transaction = new sql.Transaction(pool);

    try {
        await transaction.begin();

        const oldResultStatus = await transaction.request()
            .input('cnp_pacient', sql.Char(13), cnpPacient)
            .query(`
            SELECT Status_activ
            FROM pacienti WHERE cnp = @cnp_pacient
        `);

        if(oldResultStatus.recordset[0].Status_activ != status) {
            console.log("aici")
            // 1. Actualizare status pacient
            const statusQuery = await transaction.request()
                .input('status', sql.Bit, status)
                .input('cnp', sql.Char(13), cnpPacient)
                .query(`UPDATE pacienti
                        SET Status_activ = @status
                        WHERE CNP = @cnp`);

            // Logare modificare status
            await transaction.request()
                .input('cnpMedic', sql.VarChar(13), cnpMedic)
                .input('tabela', sql.VarChar(50), 'pacienti')
                .input('coloana', sql.VarChar(50), 'Status_activ')
                .input('valoare_veche', sql.VarChar(100), null) // opțional: poți adăuga o interogare pentru valoarea veche
                .input('valoare_noua', sql.VarChar(100), status.toString())
                .input('data', sql.DateTime2(3), new Date())
                .input('operatie', sql.VarChar(50), 'UPDATE')
                .input('detalii', sql.VarChar(100), `CNP: ${cnpPacient}`)
                .query(`
                    INSERT INTO log_modificari
                    (cnp_medic, tabela_modificata, coloana_modificata, valoare_veche, valoare_noua, data_modificare,
                     operatie, detalii)
                    VALUES (@cnpMedic, @tabela, @coloana, @valoare_veche, @valoare_noua, @data, @operatie, @detalii)
                `);
        }
        // 2. Actualizare praguri
        for (const prag of praguri) {
            const {...newVals } = prag;

            // 1. Obține valorile vechi
            const oldResult = await transaction.request()
                .input('cnp_pacient', sql.Char(13), cnpPacient)
                .query(`
            SELECT limita_minima_puls, limita_maxima_puls,
                   limita_minima_temperatura, limita_maxima_temperatura,
                   limita_minima_umiditate, limita_maxima_umiditate,
                   limita_minima_ekg, limita_maxima_ekg
            FROM praguri_masuratori WHERE cnp_pacient = @cnp_pacient
        `);

            const oldVals = (oldResult && oldResult.recordset.length > 0) ? oldResult.recordset[0] : null;

            if (oldVals === null) {
                // E inserare nouă
                await transaction.request()
                    .input('cnp_pacient', sql.Char(13), cnpPacient)
                    .input('cnp_doctor', sql.Char(13), cnpMedic)
                    .input('minPuls', sql.Numeric(10, 2), newVals.limita_minima_puls)
                    .input('maxPuls', sql.Numeric(10, 2), newVals.limita_maxima_puls)
                    .input('minTemp', sql.Numeric(10, 2), newVals.limita_minima_temperatura)
                    .input('maxTemp', sql.Numeric(10, 2), newVals.limita_maxima_temperatura)
                    .input('minEKG', sql.Numeric(10, 2), newVals.limita_minima_ekg)
                    .input('maxEKG', sql.Numeric(10, 2), newVals.limita_maxima_ekg)
                    .input('minUmiditate', sql.Numeric(10, 2), newVals.limita_minima_umiditate)
                    .input('maxUmiditate', sql.Numeric(10, 2), newVals.limita_maxima_umiditate)
                    .query(`
                INSERT INTO praguri_masuratori 
                (cnp_pacient, limita_minima_puls, limita_maxima_puls,
                 limita_minima_temperatura, limita_maxima_temperatura,
                 limita_minima_ekg, limita_maxima_ekg,
                 cnp_medic, limita_minima_umiditate, limita_maxima_umiditate)
                VALUES (@cnp_pacient, @minPuls, @maxPuls, 
                        @minTemp, @maxTemp, 
                        @minEKG, @maxEKG, 
                        @cnp_doctor, @minUmiditate, @maxUmiditate)
            `);
                continue; // Nu mai facem comparații pentru că e inserare
            }
            // 2. Construiește lista coloanelor de verificat
            const coloane = [
                { nume: 'limita_minima_puls', veche: oldVals.limita_minima_puls, noua: newVals.limita_minima_puls },
                { nume: 'limita_maxima_puls', veche: oldVals.limita_maxima_puls, noua: newVals.limita_maxima_puls },
                { nume: 'limita_minima_temperatura', veche: oldVals.limita_minima_temperatura, noua: newVals.limita_minima_temperatura },
                { nume: 'limita_maxima_temperatura', veche: oldVals.limita_maxima_temperatura, noua: newVals.limita_maxima_temperatura },
                { nume: 'limita_minima_umiditate', veche: oldVals.limita_minima_umiditate, noua: newVals.limita_minima_umiditate },
                { nume: 'limita_maxima_umiditate', veche: oldVals.limita_maxima_umiditate, noua: newVals.limita_maxima_umiditate },
                { nume: 'limita_minima_ekg', veche: oldVals.limita_minima_ekg, noua: newVals.limita_minima_ekg },
                { nume: 'limita_maxima_ekg', veche: oldVals.limita_maxima_ekg, noua: newVals.limita_maxima_ekg }
            ];

            let shouldUpdate = false;

            for (const col of coloane) {
                if (parseFloat(col.veche) !== parseFloat(col.noua)) {
                    shouldUpdate = true;

                    await transaction.request()
                        .input('cnpMedic', sql.VarChar(13), cnpMedic)
                        .input('tabela', sql.VarChar(50), 'praguri_masuratori')
                        .input('coloana', sql.VarChar(50), col.nume)
                        .input('valoare_veche', sql.VarChar(100), col.veche.toString())
                        .input('valoare_noua', sql.VarChar(100), col.noua.toString())
                        .input('data', sql.DateTime2(3), new Date())
                        .input('operatie', sql.VarChar(50), 'UPDATE')
                        .input('detalii', sql.VarChar(100), `CNP pacient: ${cnpPacient}`)
                        .query(`
                    INSERT INTO log_modificari 
                    (cnp_medic, tabela_modificata, coloana_modificata, valoare_veche, valoare_noua, data_modificare, operatie, detalii)
                    VALUES (@cnpMedic, @tabela, @coloana, @valoare_veche, @valoare_noua, @data, @operatie, @detalii)
                `);
                }
            }

            // 3. Dacă există modificări, execută UPDATE
            if (shouldUpdate) {
                await transaction.request()
                    .input('cnp_pacient', sql.Char(13), cnpPacient)
                    .input('minPuls', sql.Numeric(10, 2), newVals.limita_minima_puls)
                    .input('maxPuls', sql.Numeric(10, 2), newVals.limita_maxima_puls)
                    .input('minTemp', sql.Numeric(10, 2), newVals.limita_minima_temperatura)
                    .input('maxTemp', sql.Numeric(10, 2), newVals.limita_maxima_temperatura)
                    .input('minUmi', sql.Numeric(10, 2), newVals.limita_minima_umiditate)
                    .input('maxUmi', sql.Numeric(10, 2), newVals.limita_maxima_umiditate)
                    .input('minEKG', sql.Numeric(10, 2), newVals.limita_minima_ekg)
                    .input('maxEKG', sql.Numeric(10, 2), newVals.limita_maxima_ekg)
                    .query(`
                UPDATE praguri_masuratori
                SET 
                    limita_minima_puls = @minPuls,
                    limita_maxima_puls = @maxPuls,
                    limita_minima_temperatura = @minTemp,
                    limita_maxima_temperatura = @maxTemp,
                    limita_minima_umiditate = @minUmi,
                    limita_maxima_umiditate = @maxUmi,
                    limita_minima_ekg = @minEKG,
                    limita_maxima_ekg = @maxEKG
                WHERE cnp_pacient = @cnp_pacient
            `);
            }
    }

        await transaction.commit();
        res.json({ success: true });
    } catch (err) {
        console.error('Eroare:', err);
        await transaction.rollback();
        res.status(500).json({ success: false, error: err.message });
    }
});

app.listen(3000, () => console.log('API server running on port 3000'));
