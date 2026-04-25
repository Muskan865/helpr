const express = require('express');
const router = express.Router();

const {
  getWorkerJobs,
  getWorkerBids,
  getWorkerProfile,
  getAllRequests,
  createWorkerProfile,
  getMatchingRequests,
  placeBid,
  cancelBid,
  updateJobStatus,
  submitReview
} = require('../controllers/workerController');


// ===================== REQUESTS =====================
router.get('/requests', getAllRequests);
router.get('/:id/matching-requests', getMatchingRequests);
router.post('/review', submitReview);


// ===================== WORKER DATA =====================
router.get('/:id/jobs', getWorkerJobs);
router.get('/:id/bids', getWorkerBids);
router.get('/:id/profile', getWorkerProfile);


// ===================== PROFILE =====================
router.post('/profile', createWorkerProfile);


// ===================== BID SYSTEM =====================
router.post('/:id/place-bid', placeBid);
router.delete('/bid/:id', cancelBid);


// ===================== JOB STATUS =====================
router.put('/job/:id/status', updateJobStatus);


module.exports = router;