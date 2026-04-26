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
          j.worker_id,
          sr.service_type,
          sr.description,
          sr.date,
          sr.location
        FROM job j
        JOIN service_request sr ON j.request_id = sr.id
        WHERE sr.requester_id = @requesterId
          AND j.status = 'ongoing'
      `);

    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error fetching requester jobs');
  }
};