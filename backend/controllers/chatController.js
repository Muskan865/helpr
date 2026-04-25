const { sql, poolPromise } = require("../config/db");

// 🔹 Get messages for a job
exports.getMessages = async (req, res) => {
  try {
    const { jobId } = req.params;
    const pool = await poolPromise;

    const result = await pool.request()
      .input("jobId", sql.Int, jobId)
      .query(`
        SELECT * FROM message
        WHERE job_id = @jobId
        ORDER BY message_id ASC
      `);

    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error fetching messages");
  }
};

// 🔹 Send message
exports.sendMessage = async (req, res) => {
  try {
    const { jobId, senderId, content } = req.body;
    const pool = await poolPromise;

    await pool.request()
      .input("jobId", sql.Int, jobId)
      .input("senderId", sql.Int, senderId)
      .input("content", sql.VarChar, content)
      .query(`
        INSERT INTO message (job_id, sender_id, content)
        VALUES (@jobId, @senderId, @content)
      `);

    res.send("Message sent");
  } catch (err) {
    console.error(err);
    res.status(500).send("Error sending message");
  }
};