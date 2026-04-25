const express = require('express');
const router = express.Router();

const {
  getWorkerJobs,
  getWorkerBids,
  getWorkerProfile,
  getAllRequests,
  getMatchingRequests,
  placeBid
} = require('../controllers/workerController');

router.get('/requests', getAllRequests);
router.post('/:id/place-bid', placeBid);

router.get('/:id/jobs', getWorkerJobs);
router.get('/:id/bids', getWorkerBids);
router.get('/:id/profile', getWorkerProfile);
router.get('/:id/matching-requests', getMatchingRequests);

module.exports = router;