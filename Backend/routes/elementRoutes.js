const express = require("express");
const router = express.Router();
const elementController = require("../controllers/elementController");
const auth = require("../middleware/auth");
const upload = require("../middleware/multer");

// Create element
router.post("/", auth, upload.single("image"), elementController.createElement);

// Get elements by category
router.get("/category/:categoryId", elementController.getElementsByCategory);

// Update element
router.put(
  "/:id",
  auth,
  upload.single("image"),
  elementController.updateElement
);

// Delete element
router.delete("/:id", auth, elementController.deleteElement);

// Toggle recommendation status
router.patch("/:id/toggle-recommendation", auth, elementController.toggleRecommendation);

// Get recommended elements
router.get("/recommended", elementController.getRecommendedElements);

module.exports = router;
