const express = require('express');
const router = express.Router();
const { getRequesterJobs } = require('../controllers/requesterController');

router.get('/:id/jobs', getRequesterJobs);

module.exports = router;