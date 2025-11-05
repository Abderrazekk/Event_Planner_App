const Media = require("../models/Media");
const Element = require("../models/Element");
const fs = require("fs");
const path = require("path");

// Upload media for an element
exports.uploadMedia = async (req, res) => {
  try {
    const { elementId, type } = req.body;

    if (!elementId || !type) {
      return res.status(400).json({ msg: "Element ID and media type are required" });
    }

    if (!req.file) {
      return res.status(400).json({ msg: "Media file is required" });
    }

    // Check if element exists
    const element = await Element.findById(elementId);
    if (!element) {
      return res.status(404).json({ msg: "Element not found" });
    }

    const newMedia = new Media({
      elementId,
      filename: req.file.filename,
      originalName: req.file.originalname,
      path: `/uploads/media/${req.file.filename}`,
      type
    });

    await newMedia.save();

    res.status(201).json({
      _id: newMedia._id,
      filename: newMedia.filename,
      originalName: newMedia.originalName,
      path: newMedia.path,
      type: newMedia.type,
      uploadedAt: newMedia.uploadedAt
    });
  } catch (err) {
    console.error("Upload media error:", err.message);
    res.status(500).json({ msg: "Server error", error: err.message });
  }
};

// Get all media for an element
exports.getMediaByElement = async (req, res) => {
  try {
    const { elementId } = req.params;

    const media = await Media.find({ elementId }).sort({ uploadedAt: -1 });

    res.json(media);
  } catch (err) {
    console.error("Get media error:", err.message);
    res.status(500).send("Server error");
  }
};

// Delete media
exports.deleteMedia = async (req, res) => {
  try {
    const media = await Media.findById(req.params.id);

    if (!media) {
      return res.status(404).json({ msg: "Media not found" });
    }

    // Delete file from filesystem
    const filePath = path.join(__dirname, "..", media.path);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    await Media.deleteOne({ _id: media._id });

    res.json({ msg: "Media deleted successfully" });
  } catch (err) {
    console.error("Delete media error:", err.message);
    res.status(500).json({
      msg: "Server error",
      error: err.message,
    });
  }
};