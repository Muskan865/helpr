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

exports.getMatchingRequests = async (req, res) => {
  try {
    const workerId = req.params.id;
    const pool = await poolPromise;

    const workerResult = await pool.request()
      .input('workerId', workerId)
      .query(`
        SELECT profession, skills FROM worker WHERE id = @workerId
      `);

    if (workerResult.recordset.length === 0) {
      return res.status(404).json({ error: "Worker not found" });
    }

    const worker = workerResult.recordset[0];
    const profession = worker.profession.toLowerCase();
    const skills = worker.skills.toLowerCase().split(',').map(s => s.trim());

    // Get all open requests
    const requestsResult = await pool.request()
      .query(`
        SELECT * FROM service_request WHERE status = 'open'
      `);

    // Filter requests that match profession or skills
    const matchingRequests = requestsResult.recordset.filter(request => {
      const serviceType = request.service_type.toLowerCase();
      return serviceType.includes(profession) || 
             skills.some(skill => serviceType.includes(skill));
    });

    res.json(matchingRequests);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};