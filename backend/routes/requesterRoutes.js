const express = require('express');
const router = express.Router();

const {
  postServiceRequest,
  getRequesterBids,
  acceptBid,
  getRequesterActiveJobs,
  getRequesterJobHistory,
  getAllOpenRequests,
  getRequesterOpenRequests,
  getWorkerPublicProfile,
  submitRating,
  getRequesterRatings,
  getRequesterJobs
} = require('../controllers/requesterController');


router.post('/request', postServiceRequest);
router.get('/requests/open', getAllOpenRequests);
router.get('/:id/requests/open', getRequesterOpenRequests);

router.get('/:id/bids', getRequesterBids);
router.put('/bid/:id/accept', acceptBid);


router.get('/:id/active-jobs', getRequesterActiveJobs);
router.get('/:id/job-history', getRequesterJobHistory);
router.get('/:id/jobs', getRequesterJobs);



router.get('/worker/:id/profile', getWorkerPublicProfile);


router.post('/rating', submitRating);
router.get('/:id/ratings', getRequesterRatings);


module.exports = router;
