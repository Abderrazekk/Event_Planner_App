const express = require("express");
const router = express.Router();
const recommendationController = require("../controllers/recommendationController");
const auth = require("../middleware/auth");
const admin = require("../middleware/admin");

// Toggle recommendation status (Admin only)
router.patch("/:id/toggle", auth, admin, recommendationController.toggleRecommendation);

// Get recommended elements (Public)
router.get("/", recommendationController.getRecommendedElements);

module.exports = router;