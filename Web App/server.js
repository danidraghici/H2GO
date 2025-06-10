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
        const result = await sql.query`SELECT * FROM Utilizatori WHERE email = ${email}`;

        if (result.recordset.length === 0) {
            return res.status(401).json({ success: false, message: 'Invalid credentials' });
        }

        const user = result.recordset[0];

        const passwordMatch = await bcrypt.compare(password, user.parola_hash);

        if (!passwordMatch) {
            return res.status(401).json({ success: false, message: 'Invalid credentials' });
        }

        // const token = jwt.sign({ id: user.ID, email: user.Email }, JWT_SECRET, { expiresIn: '1h' });

        res.status(200).json({ success: true, user: { id: user.id, username: user.username, email: user.email, userType: user.rol, cnp: user.CNP } });
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

        // Obține ultima alertă pentru pacient
        const alertaResult = await request.query(`
            SELECT TOP 1
                mesaj,
                severitate,
                status,
                data_generare
            FROM alerte
            WHERE cnp_pacient = '${cnp}'
            ORDER BY data_generare DESC, id DESC
        `);

        if (result.recordset.length === 0) {
            masuratori = {
                ekg: 0,
                puls: parseFloat(0),
                umiditate: parseFloat(0),
                temperatura: parseFloat(0),
                data_masurare: 0,
                alerta: null
            };
        }
    else {
            const latest = result.recordset[0];
            const alerta = alertaResult.recordset[0];

            masuratori = {
                ekg: ecgResult.recordset.map(r => parseFloat(r.masurare_ekg)).reverse(), // pentru grafic, ordonat crescător după timp
                puls: parseFloat(latest.masurare_puls),
                umiditate: parseFloat(latest.masurare_umiditate),
                temperatura: parseFloat(latest.masurare_temperatura),
                data_masurare: latest.data_masurare,
                alerta: alerta ? {
                    mesaj: alerta.mesaj,
                    severitate: alerta.severitate,
                    status: alerta.status,
                    data_generare: alerta.data_generare
                } : null
            };
        }
        console.log(`Masuratori pentru CNP ${cnp}:`, masuratori);
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
                    (cnp_doctor, tabela_modificata, coloana_modificata, valoare_veche, valoare_noua, data_modificare,
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
                    (cnp_doctor, tabela_modificata, coloana_modificata, valoare_veche, valoare_noua, data_modificare, operatie, detalii)
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

app.post('/api/consultatii', async (req, res) => {
    const cnp_pacient = req.query.cnp_pacient;
    const cnp_doctor = req.query.cnp_medic;

    console.log(cnp_pacient);
    if (!cnp_pacient) {
        return res.status(400).json({ message: "CNP pacient lipsă." });
    }

    const { diagnostic, tratament, recomandari, observatii } = req.body;
    const data_programare = new Date();
    const data_consultatie = new Date();

    try {
        const pool = await sql.connect(config);

        // 1. Inserăm programarea
        const programareResult = await pool.request()
            .input('cnp_pacient', sql.Char(13), cnp_pacient)
            .input('cnp_doctor', sql.Char(13), cnp_doctor)
            .input('data_programare', sql.Date, data_programare)
            .input('status', sql.VarChar(50), 'finalizata')
            .input('comentarii', sql.Text, '')
            .query(`
                INSERT INTO programari (cnp_pacient, cnp_doctor, data_programare, status, comentarii)
                OUTPUT INSERTED.id
                VALUES (@cnp_pacient, @cnp_doctor, @data_programare, @status, @comentarii)
            `);

        const id_programare = programareResult.recordset[0].id;

        // 2. Inserăm consultația
        await pool.request()
            .input('id_programare', sql.Int, id_programare)
            .input('diagnostic', sql.Text, diagnostic)
            .input('tratament', sql.Text, tratament)
            .input('recomandari', sql.Text, recomandari)
            .input('data_consultatie', sql.DateTime2(3), data_consultatie)
            .input('observatii', sql.Text, observatii)
            .query(`
                INSERT INTO consultatii (id_programare, diagnostic, tratament, recomandari, data_consultatie, observatii)
                VALUES (@id_programare, @diagnostic, @tratament, @recomandari, @data_consultatie, @observatii)
            `);

        // 3. Mutăm tratamentele vechi în istoric
        const tratamenteVeche = await pool.request()
            .input('cnp_pacient', sql.Char(13), cnp_pacient)
            .query(`
        SELECT * FROM medicatie_curenta WHERE cnp_pacient = @cnp_pacient
    `);

        for (const t of tratamenteVeche.recordset) {
            await pool.request()
                .input('cnp_doctor', sql.Char(13), t.cnp_doctor)
                .input('cnp_pacient', sql.Char(13), t.cnp_pacient)
                .input('denumire_medicament', sql.VarChar(100), t.denumire_medicament)
                .input('forma_farmaceutica', sql.VarChar(100), t.forma_farmaceutica)
                .input('posologie', sql.VarChar(50), t.posologie)
                .input('data_incepere', sql.Date, t.data_incepere)
                .input('data_finalizare', sql.Date, new Date())
                .input('motiv_intrerupere', sql.Text, 'Finalizare consultație')
                .query(`
            INSERT INTO istoric_medicatie (
                cnp_doctor, cnp_pacient, denumire_medicament,
                forma_farmaceutica, posologie, data_incepere,
                data_finalizare, motiv_intrerupere
            )
            VALUES (
                @cnp_doctor, @cnp_pacient, @denumire_medicament,
                @forma_farmaceutica, @posologie, @data_incepere,
                @data_finalizare, @motiv_intrerupere
            )
        `);
        }

        // 4. Ștergem din medicatie_curenta
        await pool.request()
            .input('cnp_pacient', sql.Char(13), cnp_pacient)
            .query(`DELETE FROM medicatie_curenta WHERE cnp_pacient = @cnp_pacient`);

        const tratamenteNoi = tratament
            .split('\n')
            .map(l => l.trim())
            .filter(l => l.length > 0);

        for (const linie of tratamenteNoi) {
            const [denumire, forma, posologie] = linie.split(';').map(s => s.trim());
            if (!denumire || !forma) continue;

            await pool.request()
                .input('cnp_doctor', sql.Char(13), cnp_doctor)
                .input('cnp_pacient', sql.Char(13), cnp_pacient)
                .input('denumire_medicament', sql.VarChar(100), denumire)
                .input('forma_farmaceutica', sql.VarChar(100), forma)
                .input('posologie', sql.Text, posologie || '')
                .input('data_incepere', sql.Date, new Date())
                .input('data_ultima_prescriere', sql.Date, new Date())
                .query(`
            INSERT INTO medicatie_curenta (
                cnp_doctor, cnp_pacient, denumire_medicament,
                forma_farmaceutica, posologie, data_incepere, data_ultima_prescriere
            )
            VALUES (
                @cnp_doctor, @cnp_pacient, @denumire_medicament,
                @forma_farmaceutica, @posologie, @data_incepere, @data_ultima_prescriere
            )
        `);
        }


        res.status(201).json({ message: 'Consultația a fost salvată.' });
    } catch (err) {
        console.error("Eroare salvare:", err);
        res.status(500).json({ message: 'Eroare la salvare în baza de date.' });
    }
});

app.get('/api/date-monitorizare', async (req, res) => {
    const { cnp, perioada } = req.query;

    if (!cnp || !perioada) {
        return res.status(400).json({ error: 'Parametrii lipsă: cnp sau perioada' });
    }

    let nrZile = 7;
    if (perioada.endsWith('z')) {
        nrZile = parseInt(perioada);
    } else if (perioada.endsWith('l')) {
        nrZile = parseInt(perioada) * 30;
    }

    try {
        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('cnp', sql.VarChar, cnp)
            .input('dataLimita', sql.DateTime, new Date(Date.now() - nrZile * 24 * 60 * 60 * 1000))
            .query(`
                SELECT
                masurare_puls,
                masurare_umiditate,
                masurare_temperatura,
                data_masurare
                FROM masuratori
                WHERE cnp_pacient = @cnp AND data_masurare >= @dataLimita
                ORDER BY data_masurare ASC
            `);

        res.json(result.recordset);
    } catch (err) {
        console.error('Eroare DB:', err);
        res.status(500).json({ error: 'Eroare server sau conexiune SQL' });
    }
});


const { sharePatientToFhir } = require('./utils/fhirService');

app.post('/api/pacienti/:id/share-fhir', async (req, res) => {
    const { id } = req.params;

    try {
        await sql.connect(config);

        // Pacient
        const resultPacient = await sql.query`SELECT * FROM pacienti WHERE CNP = ${id}`;
        if (resultPacient.recordset.length === 0) {
            return res.status(404).json({ success: false, message: 'Pacientul nu a fost găsit' });
        }
        const pacient = resultPacient.recordset[0];

        // Medicație curentă
        const resultMedCurenta = await sql.query`
      SELECT * FROM medicatie_curenta WHERE cnp_pacient = ${id}
    `;

        // Istoric medicație
        const resultIstoricMed = await sql.query`
      SELECT * FROM istoric_medicatie WHERE cnp_pacient = ${id}
    `;

        // Adaugă datele medicației pacientului în obiectul pacient
        pacient.medicationCurrent = resultMedCurenta.recordset;
        pacient.medicationHistory = resultIstoricMed.recordset;

        // Apelează funcția care construiește resursa FHIR cu toate datele
        const rezultatFhir = await sharePatientToFhir(pacient);

        res.json({ success: true, message: 'Pacient partajat cu succes în FHIR.', rezultatFhir });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Eroare la partajare FHIR.' });
    }
});


function verificaAlerte(valori, praguri) {
  const alerte = [];
console.log(`praguri func: ${JSON.stringify(praguri)}`);
  function verifica(label, val, min, max, severitateDacaDepaseste) {
    if (val < min || val > max) {
      return {
        mesaj: `${label} iesit din limite: ${val} (limite: ${min} - ${max})`,
        severitate: severitateDacaDepaseste
      };
    }
    return null;
  }

  const alertaPuls = verifica("Puls", valori.puls, praguri.limita_minima_puls, praguri.limita_maxima_puls, valori.puls > praguri.limita_maxima_puls ? "mare" : "medie");
  if (alertaPuls) alerte.push(alertaPuls);

  const alertaTemp = verifica("Temperatura", valori.temperatura, praguri.limita_minima_temperatura, praguri.limita_maxima_temperatura, "medie");
  if (alertaTemp) alerte.push(alertaTemp);

//   const alertaEKG = verifica("EKG", valori.ekg, praguri.min_ekg, praguri.max_ekg, "mare");
//   if (alertaEKG) alerte.push(alertaEKG);

  const alertaUmiditate = verifica("Umiditate", valori.umiditate, praguri.limita_minima_umiditate, praguri.limita_maxima_umiditate, "mica");
  if (alertaUmiditate) alerte.push(alertaUmiditate);

  return alerte;
}


app.post('/api/insert', async (req, res) => {
  const { cnp, masurare_ekg, masurare_puls, masurare_umiditate, masurare_temperatura } = req.body;

const ekg = masurare_ekg;
const puls = masurare_puls;
const uminditate = masurare_umiditate;
const temperatura = masurare_temperatura;
  try {
    await sql.connect(config);

    // Ia CNP pe baza emailului
    // const result = await sql.query`SELECT CNP FROM utilizatori WHERE email = ${email}`;
    // if (result.recordset.length === 0) {
    //   return res.status(404).json({ message: 'Utilizator inexistent' });
    // }
// console.log(result);
    // const cnp = result.recordset[0].CNP;
// console.log(cnp); // ➡️ '6020220234523'

    const timestamp = new Date().toISOString();
    function generateRandomId() {
  return Math.floor(100000 + Math.random() * 900000);

}

console.log(`CNP: ${cnp}`);
let id1 = generateRandomId();
   const praguriResult = await sql.query(`
   SELECT TOP (1) *
            FROM praguri_masuratori
            WHERE cnp_pacient = ${cnp}
`);
const praguri = praguriResult.recordset[0];
console.log(`praguri: ${JSON.stringify(praguri)}`);
if (!praguri) {
  throw new Error("Pragurile nu au fost găsite pentru pacientul cu CNP: " + cnp);
}


   const result = await sql.query(`
      INSERT INTO masuratori (cnp_pacient, masurare_ekg, masurare_puls,masurare_umiditate, masurare_temperatura, data_masurare)
      OUTPUT INSERTED.id AS masurare_id
      VALUES
        ('${cnp}',${ekg}, ${puls}, ${uminditate}, ${temperatura}, '${timestamp}')
    `);
const insertedId = result.recordset[0].masurare_id;

console.log('Inserted ID:', insertedId); // Verifică ID-ul inserat
const valori = {
  puls: puls,
  temperatura: temperatura,
  ekg: ekg,
  umiditate: uminditate
};

const alerteGenerate = verificaAlerte(valori, praguri);
console.log(alerteGenerate);
// const alerte = [];

// const pulseAlert = verifica("Puls", puls, praguri.min_puls, praguri.max_puls);
// console.log(`pulseAlert: ${JSON.stringify(pulseAlert)}`);
// if (pulseAlert) alerte.push(pulseAlert);

// const tempAlert = verifica("Temperatura", temperatura, praguri.min_temp, praguri.max_temp);
// if (tempAlert) alerte.push(tempAlert);

// etc. pentru celelalte
// console.log(`Alerte: ${JSON.stringify(alerte)}`);
for (const alerta of alerteGenerate) {
  await sql.query(`
    INSERT INTO alerte (cnp_pacient, masurare_id, mesaj, severitate, status, data_generare)
    VALUES ('${cnp}', ${insertedId}, '${alerta.mesaj}', '${alerta.severitate}', 'necitita', GETDATE())
  `);
}
res.json({
  message: 'Valori salvate',
  masurare_id: insertedId,
  alerteGenerate: alerteGenerate
});
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Eroare la salvare' });
  }
});



app.get('/api/history', async (req, res) => {
  const { hours = 24, userId } = req.query;

  if (!userId) {
    return res.status(400).json({ error: 'Parametrul userId este necesar' });
  }

  try {
    await sql.connect(config);

    const result = await sql.query`
      SELECT timp, puls, temperatura, glicemie
      FROM Masuratori
      WHERE timp >= DATEADD(HOUR, -${hours}, GETDATE()) AND user_id = ${userId}
      ORDER BY timp ASC
    `;

    res.json(result.recordset);
  } catch (err) {
    console.error('Eroare API history:', err);
    res.status(500).json({ error: 'Eroare server' });
  }
});

app.post('/api/login/mobile', async (req, res) => {
  const { email, password } = req.body;
  await sql.connect(config);

  try {
    // 1. Caută userul după email
    const result = await sql.query`
      SELECT *
      FROM utilizatori
      WHERE email = ${email}
    `;

    if (result.recordset.length === 0) {
      return res.status(401).json({ success: false, message: 'Email inexistent' });
    }

    const user = result.recordset[0];
    console.log(`User găsit: ${JSON.stringify(user)}`);
    console.log(password, user.parola_hash);
    const passwordMatch = await bcrypt.compare(password, user.parola_hash);
    console.log(`Parola comparată: ${passwordMatch}`);
    if (!passwordMatch) {
      return res.status(401).json({ success: false, message: 'Parolă incorectă' });
    }

    let additionalData = {};

    // 2. În funcție de rol, ia datele specifice
    switch (user.rol) {
      case 'pacient':
        const pacientData = await sql.query`
          SELECT *
          FROM Pacienti
          WHERE cnp = ${user.CNP}
        `;
        console.log(`CNP pacient: ${user.cnp}`);
        console.log(`Pacient data: ${JSON.stringify(pacientData.recordset)}`);
        if (pacientData.recordset.length > 0) {
          additionalData = pacientData.recordset[0];
        }
        console.log(`Pacient data: ${JSON.stringify(additionalData)}`);
        break;

      case 'ingrijitor':
        const ingrijitorData = await sql.query`
          SELECT *
          FROM Ingrijitori
          WHERE cnp_ingrijitor = ${user.CNP}
        `;
        console.log(user.CNP);
        console.log(`Ingrijitor data: ${JSON.stringify(ingrijitorData.recordset)}`);
        if (ingrijitorData.recordset.length > 0) {
          additionalData = ingrijitorData.recordset[0];
        }
        break;
      default:
        return res.status(400).json({ success: false, message: 'Rol necunoscut' });
    }

    // 3. Trimite înapoi totul
    return res.status(200).json({
      success: true,
      message: 'Autentificare reușită',
      user: {
        email: user.email,
        cnp: user.cnp,
        rol: user.rol,
        username: user.username || user.nume || '',
        ...additionalData,
      }
    });

  } catch (err) {
    console.error("❌ Eroare la login:", err);
    return res.status(500).json({ success: false, message: 'Eroare server' });
  }
});


app.get('/api/praguriPacient/:cnp', async (req, res) => {
 const cnp = req.params.cnp;

    try {
        await sql.connect(config);
        const result = await sql.query`
            SELECT TOP (1) *
            FROM praguri_masuratori
            WHERE cnp_pacient = ${cnp}
        `;

        if (result.recordset.length === 0) {
            return res.status(404).json({ success: false, message: 'Praguri inexistente pentru acest pacient.' });
        }
        console.log('PRAGURI',result);
        res.status(200).json({ success: true, praguri: result.recordset[0] });
    } catch (err) {
        console.error('Eroare SQL:', err);
        res.status(500).json({ success: false, message: 'Eroare de server la preluarea pragurilor.' });
    }
});


// POST alerta noua
app.post('/api/alertaNoua', async (req, res) => {
  const {
    cnp_pacient,
    masurare_id,
    mesaj,
    severitate,
    status,
    data_generare
  } = req.body;


   function generateRandomId() {
  return Math.floor(100000 + Math.random() * 900000); }// 6 cifre random
  let id1 = generateRandomId();
 try {
        await sql.connect(config);
         const result = await sql.query(`
      INSERT INTO alerte (
        cnp_pacient,
        masurare_id,
        mesaj,
        severitate,
        status,
        data_generare
      ) VALUES (
        '${cnp_pacient}',
      ${masurare_id},
      '${mesaj}',
      '${severitate}',
      '${status}',
      '${data_generare}'
      )
    `);

        console.log(result);
        res.status(200).json({ success: true, praguri: result.recordset[0] });
    } catch (err) {
        console.error('Eroare SQL:', err);
        res.status(500).json({ success: false, message: 'Eroare de server la preluarea pragurilor.' });
    }
});

// Get appointments
app.get('/api/programariPerPacient/:cnp', async (req, res) => {
  const { cnp } = req.params;
  try {
    await sql.connect(config);
    const request = new sql.Request();
    request.input('cnp', sql.Char(13), cnp);
    const result = await request.query(`
      SELECT 
        p.id, p.data_programare, p.status, p.comentarii, 
        c.id_consultatie, c.diagnostic, c.tratament, c.data_consultatie
      FROM programari p
      LEFT JOIN consultatii c ON p.id = c.id_programare
      WHERE p.cnp_pacient = @cnp
      ORDER BY p.data_programare DESC
    `);
    res.json(result.recordset);
  } catch (error) {
    console.error(error);
    res.status(500).send('Eroare la încărcarea programărilor');
  }
});

// Get consultatie
app.get('/api/programari/:id/consultatie', async (req, res) => {
  const { id } = req.params;
  try {
    await sql.connect(config);
    const request = new sql.Request();
    request.input('id', sql.Int, id);
    const result = await request.query(`
      SELECT *
      FROM consultatii
      WHERE id_programare = @id
    `);
    if (result.recordset.length === 0) {
      return res.status(404).json({ message: 'Consultatie inexistentă' });
    }
    res.json(result.recordset[0]);
  } catch (error) {
    console.error(error);
    res.status(500).send('Eroare la încărcarea consultatiei');
  }
});


// GET /api/medicatie_curenta/:cnp
app.get('/api/medicatie_curenta/:cnp', async (req, res) => {
  const { cnp } = req.params;
  try {
    await sql.connect(config);
    const result = await sql.query(`
      SELECT cnp_doctor, cnp_pacient, denumire_medicament, forma_farmaceutica, posologie, data_incepere, data_ultima_prescriere, id
      FROM medicatie_curenta
      WHERE cnp_pacient = '${cnp}'
    `);
    console.log('MEDICATIE',result);
    res.json(result.recordset);
  } catch (err) {
    console.error('Eroare medicatie curenta:', err);
    res.status(500).json({ message: 'Eroare server medicatie curenta' });
  }
});

// GET /api/alergeni/:cnp
app.get('/api/alergeni/:cnp', async (req, res) => {
  const { cnp } = req.params;
  try {
    await sql.connect(config);
    const result = await sql.query(`
      SELECT id, cnp_pacient, substanta, status, data_inregistrare, cnp_doctor
      FROM alergeni
      WHERE cnp_pacient = '${cnp}'
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('Eroare alergeni:', err);
    res.status(500).json({ message: 'Eroare server alergeni' });
  }
});

// GET /api/istoric_medicatie/:cnp
app.get('/api/istoric_medicatie/:cnp', async (req, res) => {
  const { cnp } = req.params;
  try {
    await sql.connect(config);
    const result = await sql.query(`
      SELECT cnp_doctor, cnp_pacient, denumire_medicament, forma_farmaceutica, posologie, data_incepere, data_finalizare, motiv_intrerupere, id
      FROM istoric_medicatie
      WHERE cnp_pacient = '${cnp}'
    `);
    console.log('ISTORIC MEDICATIE', result);
    res.json(result.recordset);
  } catch (err) {
    console.error('Eroare istoric:', err);
    res.status(500).json({ message: 'Eroare server istoric medicatie' });
  }
});

// GET /api/alerte/:cnp
app.get('/api/alerte/:cnp', async (req, res) => {
  const { cnp } = req.params;

  try {
    await sql.connect(config);
    const result = await sql.query(`
      SELECT id, mesaj, severitate, status, data_generare
      FROM alerte
      WHERE cnp_pacient = '${cnp}'
      ORDER BY data_generare DESC
    `);
console.log('ALERTE', result);
    res.json(result.recordset);
  } catch (err) {
    console.error("❌ Eroare la interogare alerte:", err);
    res.status(500).json({ message: 'Eroare la încărcarea alertelor.' });
  }
});

app.listen(3000, () => console.log('API server running on port 3000'));
