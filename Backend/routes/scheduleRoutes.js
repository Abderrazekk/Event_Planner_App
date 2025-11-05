const express = require("express");
const router = express.Router();
const scheduleController = require("../controllers/scheduleController");
const auth = require("../middleware/auth");

// Toggle date mark
router.post("/", auth, scheduleController.toggleMarkedDate);

// Get marked dates for element
router.get("/:elementId", scheduleController.getMarkedDates);

// Unmark specific date
router.post("/unmark", auth, scheduleController.unmarkDate);

module.exports = router;