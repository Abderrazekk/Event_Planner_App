const express = require("express");
const router = express.Router();
const mediaController = require("../controllers/mediaController");
const auth = require("../middleware/auth");
const upload = require("../middleware/multerMedia");

// Upload media for element
router.post("/", auth, upload.single("media"), mediaController.uploadMedia);

// Get all media for element
router.get("/element/:elementId", mediaController.getMediaByElement);

// Delete media
router.delete("/:id", auth, mediaController.deleteMedia);

module.exports = router;