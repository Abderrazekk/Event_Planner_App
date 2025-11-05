const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');
const auth = require('../middleware/auth');
const admin = require('../middleware/admin');
const upload = require('../middleware/multer');

// Create category (Admin only)
router.post('/', auth, admin, upload.single('image'), categoryController.createCategory);

// Get all categories (Public)
router.get('/', categoryController.getCategories);

// Update category (Admin only)
router.put('/:id', auth, admin, upload.single('image'), categoryController.updateCategory);

// Delete category (Admin only)
router.delete('/:id', auth, admin, categoryController.deleteCategory);

module.exports = router;