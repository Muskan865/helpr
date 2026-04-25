const { poolPromise } = require("../config/db");

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
          u.full_name AS client_name,
          u.id AS client_id,
          b.bid_amount

        FROM job j

        JOIN service_request sr 
          ON j.request_id = sr.id

        JOIN users u 
          ON sr.requester_id = u.id  

        JOIN bid b 
          ON b.request_id = j.request_id 
          AND b.worker_id = j.worker_id

        WHERE j.worker_id = @workerId
      `);

    res.json(result.recordset);
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

    const result = await pool.request().input("workerId", workerId).query(`
        SELECT 
          b.id AS bid_id,
          b.request_id,
          b.worker_id,
          b.bid_amount,
          b.status AS bid_status,

          r.requester_id,
          r.service_type,
          r.description,
          r.date,
          r.time,
          r.location

        FROM bid b
        JOIN service_request r 
          ON b.request_id = r.id

        WHERE b.worker_id = @workerId
        AND b.status = 'pending'
      `);

    res.json(result.recordset);
    console.log("Bids fetched successfully ");
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

    const result = await pool.request().input("workerId", workerId).query(`
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

    const result = await pool.request().query(`
        SELECT *
        FROM service_request r
        WHERE r.status = 'open'
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
      .input("workerId", workerId)
      .query(`SELECT profession, skills FROM worker WHERE id = @workerId`);

    if (workerResult.recordset.length === 0) {
      return res.status(404).json({ error: "Worker not found" });
    }

    const worker = workerResult.recordset[0];

    if (!worker.profession || !worker.skills) {
      return res.status(400).json({ error: "Worker profile incomplete" });
    }

    const profession = worker.profession.toLowerCase();
    const skills = worker.skills.toLowerCase().split(",").map((s) => s.trim());

    const requestsResult = await pool.request()
      .input("workerId", workerId)
      .query(`
        SELECT * FROM service_request r
        WHERE r.status = 'open'
        AND NOT EXISTS (
          SELECT 1 FROM bid b
          WHERE b.request_id = r.id
          AND b.worker_id = @workerId
        )
      `);

    const matchingRequests = requestsResult.recordset.filter((request) => {
      const serviceType = (request.service_type || "").toLowerCase();
      return (
        serviceType.includes(profession) ||
        skills.some((skill) => skill && serviceType.includes(skill))
      );
    });

    res.json(matchingRequests);
  } catch (err) {
    console.error("getMatchingRequests error:", err.message);
    res.status(500).json({ error: err.message });
  }
};

exports.placeBid = async (req, res) => {
  console.log(req.body);
  try {
    console.log(req.body);
    const worker_id = req.params.id;
    const { request_id, bid_amount, bid_date, bid_time, status } = req.body;

    const pool = await poolPromise;

    await pool
      .request()
      .input("request_id", request_id)
      .input("worker_id", worker_id)
      .input("bid_amount", bid_amount)
      .input("bid_date", bid_date)
      .input("bid_time", bid_time)
      .input("status", status).query(`
        INSERT INTO bid (request_id, worker_id, bid_amount, bid_date, bid_time, status)
        VALUES (@request_id, @worker_id, @bid_amount, @bid_date, @bid_time, @status)
      `);

    res.json({ success: true, message: "Bid placed successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.cancelBid = async (req, res) => {
  try {
    const bidId = req.params.id;

    const pool = await poolPromise;

    // First check if bid exists and is still pending
    const check = await pool.request().input("bidId", bidId).query(`
        SELECT status 
        FROM bid 
        WHERE id = @bidId
      `);

    if (check.recordset.length === 0) {
      return res.status(404).json({ message: "Bid not found" });
    }

    if (check.recordset[0].status !== "pending") {
      return res.status(400).json({
        message: "Only pending bids can be cancelled",
      });
    }

    await pool.request().input("bidId", bidId).query(`
        DELETE FROM bid
        WHERE id = @bidId
      `);

    return res.json({ message: "Bid cancelled successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};

exports.updateJobStatus = async (req, res) => {
  try {
    const jobId = req.params.id;
    const { status } = req.body;

    const pool = await poolPromise;

    await pool.request()
      .input('jobId', jobId)
      .input('status', status)
      .query(`
        UPDATE job
        SET status = @status
        WHERE id = @jobId
      `);

    res.json({ message: "Status updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};

exports.submitReview = async (req, res) => {
  try {
    const { reviewer_id, reviewee_id, rating, comment } = req.body;
    console.log("Review data received:", req.body);
    const pool = await poolPromise;

    await pool.request()
      .input('reviewer_id', reviewer_id)
      .input('reviewee_id', reviewee_id)
      .input('rating', rating)
      .input('comment', comment)
      .query(`
        INSERT INTO rating_review (reviewer_id, reviewee_id, rating, comment)
        VALUES (@reviewer_id, @reviewee_id, @rating, @comment)
      `);

    res.json({ message: "Review submitted" });
  } catch (err) {
    console.error("submitReview FULL ERROR:", err.message);
    res.status(500).json({ error: err.message });
  }
};