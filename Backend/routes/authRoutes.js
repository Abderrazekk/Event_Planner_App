const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const auth = require('../middleware/auth');
const upload = require('../middleware/multer');

// Register user
router.post('/register', upload.single('profileImage'), authController.registerUser);

// Login user
router.post('/login', authController.loginUser);

// Update profile image
router.patch('/update-profile-image', auth, upload.single('profileImage'), authController.updateProfileImage);

// Get user profile
router.get('/user', auth, authController.getUserProfile);

// Admin login
router.post('/admin-login', authController.adminLogin);

// Change user password
router.patch('/change-password', auth, authController.changePasswordWithoutCurrent);

// Get user statistics (admin only)
router.get('/user-stats', auth, authController.getUserStats);

module.exports = router;