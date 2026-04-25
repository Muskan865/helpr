const { poolPromise, sql } = require('../config/db');

// REQUESTER PROFILE COMPLETION - Upload profile picture
exports.completeRequesterProfile = async (req, res) => {
  try {
    const userId = parseInt(req.body.userId, 10);
    const profilePicture = req.file ? req.file.buffer : null;

    if (!userId || Number.isNaN(userId)) {
      return res.status(400).json({ message: "User ID is required" });
    }
    if (!profilePicture) {
      return res.status(400).json({ message: "Profile picture is required" });
    }

    const pool = await poolPromise;

    if (profilePicture) {
      await pool.request()
        .input('userId', userId)
        .input('profilePicture', sql.VarBinary(sql.MAX), profilePicture)
        .query(`
          UPDATE users 
          SET profile_picture = @profilePicture 
          WHERE id = @userId
        `);
    }

    return res.json({
      message: "Requester profile completed successfully",
      userId: userId
    });

  } catch (err) {
    console.error("Requester profile completion error:", err);
    return res.status(500).json({
      message: "Failed to complete profile",
      error: err.message
    });
  }
};

// WORKER PROFILE COMPLETION - Upload profile picture and create worker profile
exports.completeWorkerProfile = async (req, res) => {
  try {
    const userId = parseInt(req.body.userId, 10);
    const profession = req.body.profession;
    const skills = req.body.skills;
    const experienceYears = parseInt(req.body.experience_years, 10);
    const profilePicture = req.file ? req.file.buffer : null;

    // Validate required fields
    if (!userId || Number.isNaN(userId)) {
      return res.status(400).json({ message: "User ID is required" });
    }
    if (!profession) {
      return res.status(400).json({ message: "Profession is required" });
    }
    if (!skills) {
      return res.status(400).json({ message: "Skills are required" });
    }
    if (Number.isNaN(experienceYears)) {
      return res.status(400).json({ message: "Experience years is required" });
    }
    if (!profilePicture) {
      return res.status(400).json({ message: "Profile picture is required" });
    }

    const pool = await poolPromise;

    // Update user profile picture if provided
    if (profilePicture) {
      await pool.request()
        .input('userId', userId)
        .input('profilePicture', sql.VarBinary(sql.MAX), profilePicture)
        .query(`
          UPDATE users 
          SET profile_picture = @profilePicture 
          WHERE id = @userId
        `);
    }

    // Create worker profile
    const result = await pool.request()
      .input('userId', userId)
      .input('profession', profession)
      .input('skills', skills)
      .input('experienceYears', experienceYears)
      .query(`
        INSERT INTO worker (user_id, profession, skills, experience_years)
        VALUES (@userId, @profession, @skills, @experienceYears);

        SELECT SCOPE_IDENTITY() AS workerId;
      `);

    return res.json({
      message: "Worker profile completed successfully",
      userId: userId,
      workerId: result.recordset[0].workerId
    });

  } catch (err) {
    console.error("Worker profile completion error:", err);
    return res.status(500).json({
      message: "Failed to complete worker profile",
      error: err.message
    });
  }
};
