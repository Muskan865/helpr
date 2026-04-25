const { poolPromise } = require("../config/db");


// ===================== GET WORKER JOBS =====================
exports.getWorkerJobs = async (req, res) => {
  try {
    const workerId = req.params.id;
    const pool = await poolPromise;

    const result = await pool.request()
      .input("workerId", workerId)
      .query(`
        SELECT 
          j.*, 
          sr.service_type, 
          sr.description, 
          sr.location, 
          sr.date, 
          sr.time,
          u.full_name AS client_name
        FROM job j
        JOIN service_request sr ON j.request_id = sr.id
        JOIN users u ON sr.requester_id = u.id  
        WHERE j.worker_id = @workerId
      `);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// ===================== GET WORKER BIDS =====================
exports.getWorkerBids = async (req, res) => {
  try {
    const workerId = req.params.id;
    const pool = await poolPromise;

    const result = await pool.request()
      .input("workerId", workerId)
      .query(`
        SELECT b.*, r.service_type, r.description, r.date, r.time, r.location
        FROM bid b
        JOIN service_request r ON b.request_id = r.id
        WHERE b.worker_id = @workerId
      `);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// ===================== GET WORKER PROFILE =====================
exports.getWorkerProfile = async (req, res) => {
  try {
    const workerId = req.params.id;
    const pool = await poolPromise;

    const result = await pool.request()
      .input("workerId", workerId)
      .query(`
        SELECT u.full_name, u.avg_rating, w.profession, w.skills, w.experience_years
        FROM worker w
        JOIN users u ON w.user_id = u.id
        WHERE w.user_id = @workerId
      `);

    if (result.recordset.length === 0) {
      return res.status(404).json({ message: "Worker not found" });
    }

    res.json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// ===================== GET ALL REQUESTS =====================
exports.getAllRequests = async (req, res) => {
  try {
    const pool = await poolPromise;

    const result = await pool.request().query(`
      SELECT *
      FROM service_request
      WHERE status = 'open'
    `);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// ===================== CREATE / UPDATE WORKER PROFILE =====================
exports.createWorkerProfile = async (req, res) => {
  try {
    const { user_id, profession, skills, experience_years } = req.body;
    const pool = await poolPromise;

    const existing = await pool.request()
      .input('user_id', user_id)
      .query(`SELECT * FROM worker WHERE user_id = @user_id`);

    if (existing.recordset.length > 0) {
      await pool.request()
        .input('user_id', user_id)
        .input('profession', profession)
        .input('skills', skills)
        .input('experience_years', experience_years)
        .query(`
          UPDATE worker
          SET profession = @profession,
              skills = @skills,
              experience_years = @experience_years
          WHERE user_id = @user_id
        `);

      return res.json({ message: "Profile updated successfully" });
    }

    await pool.request()
      .input('user_id', user_id)
      .input('profession', profession)
      .input('skills', skills)
      .input('experience_years', experience_years)
      .query(`
        INSERT INTO worker (user_id, profession, skills, experience_years)
        VALUES (@user_id, @profession, @skills, @experience_years)
      `);

    res.json({ message: "Profile created successfully" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};