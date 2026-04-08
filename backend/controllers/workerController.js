const { poolPromise } = require('../config/db');

exports.getWorkerJobs = async (req, res) => {
  try {
    console.log("Connected to API");
    const workerId = req.params.id;
    console.log("Worker ID:", workerId);

    const pool = await poolPromise;

    const result = await pool.request()
      .input('workerId', workerId)
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
    console.log("Jobs fetched successfully");
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getWorkerBids = async (req, res) => {
  try {
    console.log("Connected to API");
    const workerId = req.params.id;
    console.log("Worker ID:", workerId);
    const pool = await poolPromise;

    const result = await pool.request()
      .input('workerId', workerId)
      .query(`
        SELECT b.*, sr.description
        FROM bid b
        JOIN service_request sr ON b.request_id = sr.id
        WHERE b.worker_id = @workerId
      `);

    res.json(result.recordset);
    console.log("Bids fetched successfully");
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getWorkerProfile = async (req, res) => {
  try {
    console.log("Connected to API");
    const workerId = req.params.id;
    console.log("Worker ID:", workerId);

    const pool = await poolPromise;

    const result = await pool.request()
      .input('workerId', workerId)
      .query(`
        SELECT u.full_name, u.avg_rating, w.profession, w.skills, w.experience_years
        FROM worker w
        JOIN users u ON w.user_id = u.id
        WHERE w.id = @workerId
      `);

    res.json(result.recordset[0]);
    console.log("Profile fetched successfully");
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getAllRequests = async (req, res) => {
  try {
    console.log("Connected to API");

    const pool = await poolPromise;

    const result = await pool.request()
      .query(`
        SELECT s.*
        FROM service_request s
        WHERE s.status = 'open'
      `);

    res.json(result.recordset);
    console.log("Requests fetched successfully:", result.recordset.length);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};