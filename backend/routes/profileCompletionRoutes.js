const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const {
  completeRequesterProfile,
  completeWorkerProfile
} = require('../controllers/profileCompletionController');

const allowedExtensions = new Set(['.png', '.jpg', '.jpeg']);
const allowedMimeTypes = new Set(['image/png', 'image/jpeg', 'image/jpg']);

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const extension = path.extname(file.originalname || '').toLowerCase();
    const isExtensionAllowed = allowedExtensions.has(extension);
    const isMimeAllowed = allowedMimeTypes.has((file.mimetype || '').toLowerCase());

    if (isExtensionAllowed || isMimeAllowed) {
      cb(null, true);
      return;
    }
    cb(new Error('Only PNG and JPG/JPEG files are allowed'));
  }
});

const uploadProfilePicture = (req, res, next) => {
  upload.single('profile_picture')(req, res, (err) => {
    if (!err) {
      next();
      return;
    }

    if (err instanceof multer.MulterError && err.code === 'LIMIT_FILE_SIZE') {
      res.status(400).json({ message: 'Profile picture must be 5MB or smaller' });
      return;
    }

    res.status(400).json({ message: err.message || 'Invalid profile picture upload' });
  });
};

// Requester profile completion (upload profile picture)
router.post('/requester', uploadProfilePicture, completeRequesterProfile);

// Worker profile completion (profile picture, profession, skills, experience)
router.post('/worker', uploadProfilePicture, completeWorkerProfile);

module.exports = router;
