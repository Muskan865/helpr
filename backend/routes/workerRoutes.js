const express = require('express');
const router = express.Router();

const {
  getWorkerJobs,
  getWorkerBids,
  getWorkerProfile,
} = require('../controllers/workerController');

router.get('/:id/jobs', getWorkerJobs);
router.get('/:id/bids', getWorkerBids);
router.get('/:id/profile', getWorkerProfile);

module.exports = router;