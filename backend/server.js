const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors({
  origin: "*"
}));
app.use(express.json());

// PostgreSQL connection
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
  ssl: {
    rejectUnauthorized: false,
  },
});

// ✅ Health check route (VERY IMPORTANT for ALB)
app.get('/', (req, res) => {
  res.status(200).send("API running successfully 🚀");
});

// ✅ Add user (SAFE VERSION)
app.post('/api/users', async (req, res) => {
  try {
    // Validation
    if (!req.body || !req.body.name) {
      return res.status(400).json({ error: "Name is required" });
    }

    const { name } = req.body;

    const result = await pool.query(
      "INSERT INTO users(name) VALUES($1) RETURNING *",
      [name]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error("Error inserting user:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// ✅ Get users
app.get('/api/users', async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM users");
    res.json(result.rows);
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// Start server
app.listen(5000, '0.0.0.0', () => console.log("Server running on port 5000"));