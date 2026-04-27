const { poolPromise } = require('../config/db');
const bcrypt = require('bcrypt');

// SIGNUP
exports.signup = async (req, res) => {
  try {
    const { full_name, contact_number, password, role } = req.body;

    const pool = await poolPromise;

    // Check if user already exists
    const checkUser = await pool.request()
      .input('contact_number', contact_number)
      .query(`SELECT * FROM users WHERE contact_number = @contact_number`);

    if (checkUser.recordset.length > 0) {
      return res.status(400).json({
        message: "User already exists with this phone number"
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool.request()
      .input('full_name', full_name)
      .input('contact_number', contact_number)
      .input('password', hashedPassword)
      .input('role', role)
      .query(`
        INSERT INTO users (full_name, contact_number, password, role, profile_picture, avg_rating)
        VALUES (@full_name, @contact_number, @password, @role, 0x, 0.0);

        SELECT SCOPE_IDENTITY() AS id;
      `);

    return res.json({
      message: "User created successfully",
      userId: result.recordset[0].id,
      role: role
    });

  } catch (err) {
    return res.status(500).json({
      message: "Signup failed",
      error: "Something went wrong. Please try again."
    });
  }
};

// LOGIN
exports.login = async (req, res) => {
  try {
    const { contact_number, password } = req.body;

    const pool = await poolPromise;

    const result = await pool.request()
      .input('contact_number', contact_number)
      .query(`SELECT * FROM users WHERE contact_number = @contact_number`);

    const user = result.recordset[0];

    if (!user) {
      return res.status(400).json({
        message: "User does not exist"
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    // const isMatch = (password === user.password);

    if (!isMatch) {
      return res.status(400).json({
        message: "Incorrect password"
      });
    }

    res.json({
      message: "Login successful",
      user: {
        id: user.id,
        name: user.full_name,
        role: user.role
      }
    });

  } catch (err) {
    res.status(500).json({
      message: "Login failed",
      error: "Server error"
    });
  }
};