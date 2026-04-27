const { sql, poolPromise } = require('../config/db');

exports.getRequesterJobs = async (req, res) => {
  try {
    const requesterId = req.params.id;
    const pool = await poolPromise;

    const result = await pool.request()
      .input('requesterId', sql.Int, requesterId)
      .query(`
        SELECT 
          j.id          AS job_id,
          j.status      AS job_status,
          w.user_id     AS worker_id,
          u.full_name   AS worker_name,
          sr.service_type,
          sr.description,
          sr.date,
          sr.location
        FROM job j
        JOIN service_request sr ON j.request_id = sr.id
        JOIN worker w ON (j.worker_id = w.user_id OR j.worker_id = w.id)
        JOIN users u ON w.user_id = u.id
        WHERE sr.requester_id = @requesterId
          AND LOWER(j.status) <> 'completed'
      `);

    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error fetching requester jobs');
  }
};

exports.postServiceRequest = async (req, res) => {
  try {
    const { requester_id, service_type, description, date, time, location } = req.body;
    const pool = await poolPromise;

    await pool.request()
      .input("requester_id", requester_id)
      .input("service_type", service_type)
      .input("description", description)
      .input("date", date)
      .input("time", time)
      .input("location", location)
      .input("status", "open")
      .query(`
        INSERT INTO service_request (requester_id, service_type, description, date, time, location, status)
        VALUES (@requester_id, @service_type, @description, @date, @time, @location, @status)
      `);

    res.json({ message: "Service request posted successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


exports.getRequesterBids = async (req, res) => {
  try {
    const requesterId = req.params.id;
    const pool = await poolPromise;

    const result = await pool.request()
      .input("requesterId", requesterId)
      .query(`
        SELECT
          b.id AS bid_id,
          b.bid_amount,
          b.bid_date,
          b.bid_time,
          b.status AS bid_status,
          sr.id AS request_id,
          sr.service_type,
          sr.description,
          sr.date AS request_date,
          sr.time AS request_time,
          sr.location,
          sr.status AS request_status,
          u.id AS worker_user_id,
          u.full_name AS worker_name,
          u.avg_rating AS worker_rating,
          w.profession,
          (SELECT COUNT(*) FROM job j WHERE j.worker_id = w.user_id AND LOWER(j.status) = 'completed') AS past_jobs
        FROM bid b
        JOIN service_request sr ON b.request_id = sr.id
        JOIN worker w ON (b.worker_id = w.user_id OR b.worker_id = w.id)
        JOIN users u ON w.user_id = u.id
        WHERE sr.requester_id = @requesterId
          AND sr.status = 'open'
          AND b.status = 'pending'
      `);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


exports.acceptBid = async (req, res) => {
  try {
    const bidId = req.params.id;
    const pool = await poolPromise;

    // Get bid info
    const bidResult = await pool.request()
      .input("bidId", bidId)
      .query(`SELECT * FROM bid WHERE id = @bidId`);

    if (bidResult.recordset.length === 0) {
      return res.status(404).json({ message: "Bid not found" });
    }

    const bid = bidResult.recordset[0];

    if (bid.status !== 'pending') {
      return res.status(400).json({ message: "Only pending bids can be accepted" });
    }

    const requestCheck = await pool.request()
      .input("requestId", bid.request_id)
      .query(`
        SELECT id, status
        FROM service_request
        WHERE id = @requestId
      `);

    if (requestCheck.recordset.length === 0) {
      return res.status(404).json({ message: "Service request not found" });
    }

    if (requestCheck.recordset[0].status !== 'open') {
      return res.status(400).json({ message: "This service request is already closed" });
    }

    // Get worker user_id from worker table
    const workerResult = await pool.request()
      .input("workerId", bid.worker_id)
      .query(`SELECT user_id FROM worker WHERE id = @workerId`);

    if (workerResult.recordset.length === 0) {
      return res.status(404).json({ message: "Worker not found" });
    }

    const workerUserId = workerResult.recordset[0].user_id;

    // Create job with status 'arriving'
    await pool.request()
      .input("request_id", bid.request_id)
      .input("worker_id", bid.worker_id)
      .input("status", "arriving")
      .query(`
        INSERT INTO job (request_id, worker_id, status)
        VALUES (@request_id, @worker_id, @status)
      `);

    // Mark accepted bid
    await pool.request()
      .input("bidId", bidId)
      .query(`UPDATE bid SET status = 'accepted' WHERE id = @bidId`);

    // Reject all other bids for the same request
    await pool.request()
      .input("request_id", bid.request_id)
      .input("bidId", bidId)
      .query(`
        UPDATE bid SET status = 'rejected'
        WHERE request_id = @request_id AND id != @bidId
      `);

    // Close the service request
    await pool.request()
      .input("request_id", bid.request_id)
      .query(`UPDATE service_request SET status = 'closed' WHERE id = @request_id`);

    res.json({ message: "Bid accepted, job created" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


exports.getRequesterActiveJobs = async (req, res) => {
  try {
    const requesterId = req.params.id;
    const pool = await poolPromise;

    const result = await pool.request()
      .input("requesterId", requesterId)
      .query(`
        SELECT
          j.id AS job_id,
          j.status,
          w.user_id AS worker_id,
          sr.service_type,
          sr.description,
          sr.location,
          sr.date,
          sr.time,
          u.full_name AS worker_name,
          u.avg_rating AS worker_rating,
          u.contact_number AS worker_contact,
          w.profession,
          b.bid_amount
        FROM job j
        JOIN service_request sr ON j.request_id = sr.id
        JOIN worker w ON (j.worker_id = w.user_id OR j.worker_id = w.id)
        JOIN users u ON w.user_id = u.id
        LEFT JOIN bid b ON b.request_id = sr.id AND (b.worker_id = w.user_id OR b.worker_id = w.id) AND b.status = 'accepted'
        WHERE sr.requester_id = @requesterId
          AND (LOWER(j.status) != 'completed'
          OR (LOWER(j.status) = 'completed'
            AND NOT EXISTS (
              SELECT 1 FROM rating_review rr
              WHERE rr.reviewer_id = @requesterId
                AND rr.reviewee_id = w.user_id
            )
          ))
      `);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


exports.getRequesterJobHistory = async (req, res) => {
  try {
    const requesterId = req.params.id;
    const pool = await poolPromise;

    const result = await pool.request()
      .input("requesterId", requesterId)
      .query(`
        SELECT
          j.id AS job_id,
          j.status,
          w.user_id AS worker_id,
          sr.service_type,
          sr.description,
          sr.location,
          sr.date,
          sr.time,
          u.full_name AS worker_name,
          u.avg_rating AS worker_rating,
          u.contact_number AS worker_contact,
          w.profession,
          b.bid_amount,
          rr.rating AS my_rating,
          rr.comment AS my_comment
        FROM job j
        JOIN service_request sr ON j.request_id = sr.id
        JOIN worker w ON (j.worker_id = w.user_id OR j.worker_id = w.id)
        JOIN users u ON w.user_id = u.id
        LEFT JOIN bid b ON b.request_id = sr.id AND (b.worker_id = w.user_id OR b.worker_id = w.id) AND b.status = 'accepted'
        LEFT JOIN rating_review rr ON rr.reviewee_id = w.user_id AND rr.reviewer_id = sr.requester_id
        WHERE sr.requester_id = @requesterId
          AND LOWER(j.status) = 'completed'
      `);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


exports.getAllOpenRequests = async (req, res) => {
  try {
    const pool = await poolPromise;

    const result = await pool.request().query(`
      SELECT
        sr.*,
        u.full_name AS requester_name,
        (SELECT COUNT(*) FROM bid b WHERE b.request_id = sr.id) AS bid_count
      FROM service_request sr
      JOIN users u ON sr.requester_id = u.id
      WHERE sr.status = 'open'
      ORDER BY sr.id DESC
    `);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getRequesterOpenRequests = async (req, res) => {
  try {
    const requesterId = req.params.id;
    const pool = await poolPromise;
 
    const result = await pool.request()
      .input("requesterId", requesterId)
      .query(`
        SELECT
          sr.*,
          (SELECT COUNT(*) FROM bid b WHERE b.request_id = sr.id) AS bid_count
        FROM service_request sr
        WHERE sr.requester_id = @requesterId
          AND sr.status = 'open'
        ORDER BY sr.id DESC
      `);
 
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
 
 


exports.getWorkerPublicProfile = async (req, res) => {
  try {
    const workerId = req.params.id;
    const pool = await poolPromise;

    const result = await pool.request()
      .input("workerId", workerId)
      .query(`
        SELECT
          u.id,
          u.full_name,
          u.contact_number,
          u.avg_rating,
          u.profile_picture,
          w.profession,
          w.skills,
          w.experience_years,
          (SELECT COUNT(*) FROM job j WHERE j.worker_id = w.user_id AND LOWER(j.status) = 'completed') AS past_jobs
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


exports.submitRating = async (req, res) => {
  try {
    const { reviewer_id, reviewee_id, rating, comment, job_id } = req.body;
    const pool = await poolPromise;

    // Check if already rated this worker for this job
    const existing = await pool.request()
      .input("reviewer_id", reviewer_id)
      .input("reviewee_id", reviewee_id)
      .query(`
        SELECT * FROM rating_review
        WHERE reviewer_id = @reviewer_id AND reviewee_id = @reviewee_id
      `);

    if (existing.recordset.length > 0) {
      return res.status(400).json({ message: "You have already rated this worker" });
    }

    // Insert review
    await pool.request()
      .input("reviewer_id", reviewer_id)
      .input("reviewee_id", reviewee_id)
      .input("rating", rating)
      .input("comment", comment)
      .query(`
        INSERT INTO rating_review (reviewer_id, reviewee_id, rating, comment)
        VALUES (@reviewer_id, @reviewee_id, @rating, @comment)
      `);

    // Update worker's avg_rating
    await pool.request()
      .input("reviewee_id", reviewee_id)
      .query(`
        UPDATE users
        SET avg_rating = (
          SELECT AVG(rating) FROM rating_review WHERE reviewee_id = @reviewee_id
        )
        WHERE id = @reviewee_id
      `);

    res.json({ message: "Rating submitted successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


exports.getRequesterRatings = async (req, res) => {
  try {
    const requesterId = req.params.id;
    const pool = await poolPromise;

    const result = await pool.request()
      .input("requesterId", requesterId)
      .query(`
        SELECT
          rr.rating,
          rr.comment,
          u.full_name AS reviewer_name
        FROM rating_review rr
        JOIN users u ON rr.reviewer_id = u.id
        WHERE rr.reviewee_id = @requesterId
        ORDER BY rr.id DESC
      `);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
