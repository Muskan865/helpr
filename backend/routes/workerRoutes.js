const express = require('express');
const router = express.Router();

const {
  getWorkerJobs,
  getWorkerBids,
  getWorkerProfile,
  getAllRequests,
  getMatchingRequests,
  placeBid,
  cancelBid,
  updateJobStatus,
  submitReview
} = require('../controllers/workerController');

router.get('/requests', getAllRequests);
router.post('/:id/place-bid', placeBid);
router.delete('/bid/:id', cancelBid);
router.put('/job/:id/status', updateJobStatus);
router.post('/review', submitReview);

router.get('/:id/jobs', getWorkerJobs);
router.get('/:id/bids', getWorkerBids);
router.get('/:id/profile', getWorkerProfile);
router.get('/:id/matching-requests', getMatchingRequests);

module.exports = router;