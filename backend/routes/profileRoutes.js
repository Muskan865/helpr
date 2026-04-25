const express = require('express');
const router = express.Router();
const { getUserProfile, updateWorkerDetails } = require('../controllers/profileController');

// GET /api/profile/user/:id
router.get('/user/:id', getUserProfile);
router.put('/worker/:id', updateWorkerDetails);

module.exports = router;
