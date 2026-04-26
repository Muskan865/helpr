const { poolPromise } = require('../config/db');

const allowedProfessions = new Set([
  'Electrician',
  'Plumber',
  'Cleaner',
  'Painter',
  'Gardener',
  'Carpenter',
  'Mechanic',
  'Technician'
]);

// GET USER PROFILE (name, phone, role, profile picture)
exports.getUserProfile = async (req, res) => {
  try {
    const userId = req.params.id;

    const pool = await poolPromise;

    const result = await pool.request()
      .input('userId', userId)
      .query(`
        SELECT
          u.id,
          u.full_name,
          u.contact_number,
          u.role,
          u.profile_picture,
          u.avg_rating,
          w.profession,
          w.skills,
          w.experience_years
        FROM users u
        LEFT JOIN worker w ON u.id = w.user_id
        WHERE u.id = @userId
      `);

    if (result.recordset.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    const user = result.recordset[0];
    return res.json({
      id: user.id,
      full_name: user.full_name,
      contact_number: user.contact_number,
      role: user.role,
      avg_rating: user.avg_rating,
      profile_picture: user.profile_picture
        ? Buffer.from(user.profile_picture).toString('base64')
        : null,
      profession: user.profession ?? null,
      skills: user.skills ?? null,
      experience_years: user.experience_years ?? null
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// UPDATE WORKER-ONLY PROFILE DETAILS
exports.updateWorkerDetails = async (req, res) => {
  try {
    const userId = parseInt(req.params.id, 10);
    const profession = (req.body.profession || '').trim();
    const skills = (req.body.skills || '').trim();
    const experienceYears = parseInt(req.body.experience_years, 10);

    if (!userId || Number.isNaN(userId)) {
      return res.status(400).json({ message: 'Valid user id is required' });
    }

    if (!allowedProfessions.has(profession)) {
      return res.status(400).json({
        message: 'Profession must be one of: Electrician, Plumber, Cleaner, Painter, Gardener, Carpenter, Mechanic, Technician'
      });
    }

    if (!skills) {
      return res.status(400).json({ message: 'Skills are required' });
    }

    if (Number.isNaN(experienceYears) || experienceYears < 0) {
      return res.status(400).json({ message: 'Experience years must be a valid non-negative number' });
    }

    const pool = await poolPromise;

    const existing = await pool.request()
      .input('userId', userId)
      .query('SELECT id FROM worker WHERE user_id = @userId');

    if (existing.recordset.length === 0) {
      await pool.request()
        .input('userId', userId)
        .input('profession', profession)
        .input('skills', skills)
        .input('experienceYears', experienceYears)
        .query(`
          INSERT INTO worker (user_id, profession, skills, experience_years)
          VALUES (@userId, @profession, @skills, @experienceYears)
        `);
      return res.json({ message: 'Worker details created successfully' });
    }

    await pool.request()
      .input('userId', userId)
      .input('profession', profession)
      .input('skills', skills)
      .input('experienceYears', experienceYears)
      .query(`
        UPDATE worker
        SET profession = @profession,
            skills = @skills,
            experience_years = @experienceYears
        WHERE user_id = @userId
      `);

    return res.json({ message: 'Worker details updated successfully' });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};
