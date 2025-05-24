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

        res.status(200).json({ success: true, user: { id: user.ID, email: user.Email, userType: user.rol } });
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



app.listen(3000, () => console.log('API server running on port 3000'));
