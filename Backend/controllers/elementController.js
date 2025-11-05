const Element = require("../models/Element");
const fs = require("fs");
const path = require("path");

// Create new element
exports.createElement = async (req, res) => {
  try {
    const { name, address, price, description, category, isRecommended } =
      req.body;

    // Validate required fields
    if (!name || !address || !price || !description || !category) {
      return res.status(400).json({ msg: "All fields are required" });
    }

    if (!req.file) {
      return res.status(400).json({ msg: "Element image is required" });
    }

    const newElement = new Element({
      name,
      address,
      price,
      description,
      image: `/uploads/${req.file.filename}`,
      category,
      isRecommended: isRecommended || false,
    });

    await newElement.save();

    res.status(201).json({
      _id: newElement._id,
      name: newElement.name,
      address: newElement.address,
      price: newElement.price,
      description: newElement.description,
      image: newElement.image,
      category: newElement.category,
      isRecommended: newElement.isRecommended,
      createdAt: newElement.createdAt,
    });
  } catch (err) {
    console.error("Create element error:", err.message);
    res.status(500).json({ msg: "Server error", error: err.message });
  }
};

// Get elements by category
exports.getElementsByCategory = async (req, res) => {
  try {
    const elements = await Element.find({
      category: req.params.categoryId,
    }).sort({ createdAt: -1 });

    res.json(elements);
  } catch (err) {
    console.error("Get elements error:", err.message);
    res.status(500).send("Server error");
  }
};

// Update element
exports.updateElement = async (req, res) => {
  try {
    const { name, address, price, description, isRecommended } = req.body;
    const element = await Element.findById(req.params.id);

    if (!element) {
      return res.status(404).json({ msg: "Element not found" });
    }

    // Update image if new file provided
    if (req.file) {
      // Delete old image
      const oldImagePath = path.join(__dirname, "..", element.image);
      if (fs.existsSync(oldImagePath)) {
        fs.unlinkSync(oldImagePath);
      }
      element.image = `/uploads/${req.file.filename}`;
    }

    // Update text fields
    if (name) element.name = name;
    if (address) element.address = address;
    if (price) element.price = price;
    if (description) element.description = description;
    if (typeof isRecommended !== "undefined") {
      element.isRecommended = isRecommended;
    }

    await element.save();

    res.json({
      _id: element._id,
      name: element.name,
      address: element.address,
      price: element.price,
      description: element.description,
      image: element.image,
      category: element.category,
      isRecommended: element.isRecommended,
    });
  } catch (err) {
    console.error("Update element error:", err.message);
    res.status(500).send("Server error");
  }
};

// Delete element
exports.deleteElement = async (req, res) => {
  try {
    const element = await Element.findById(req.params.id);

    if (!element) {
      return res.status(404).json({ msg: "Element not found" });
    }

    // Delete image file
    if (element.image) {
      const imagePath = path.join(__dirname, "..", element.image);
      if (fs.existsSync(imagePath)) {
        fs.unlinkSync(imagePath);
      }
    }

    // Use deleteOne() instead of remove()
    await Element.deleteOne({ _id: element._id });

    res.json({ msg: "Element deleted successfully" });
  } catch (err) {
    console.error("Delete element error:", err.message);
    res.status(500).json({
      msg: "Server error",
      error: err.message,
    });
  }
};

// Toggle recommendation status
exports.toggleRecommendation = async (req, res) => {
  try {
    const element = await Element.findById(req.params.id);
    
    if (!element) {
      return res.status(404).json({ msg: "Element not found" });
    }

    element.isRecommended = !element.isRecommended;
    await element.save();

    res.json({
      _id: element._id,
      name: element.name,
      isRecommended: element.isRecommended
    });
  } catch (err) {
    console.error("Toggle recommendation error:", err.message);
    res.status(500).json({ msg: "Server error", error: err.message });
  }
};

// Get recommended elements
exports.getRecommendedElements = async (req, res) => {
  try {
    const elements = await Element.find({ isRecommended: true })
      .populate('category', 'name')
      .sort({ createdAt: -1 });

    res.json(elements);
  } catch (err) {
    console.error("Get recommended elements error:", err.message);
    res.status(500).send("Server error");
  }
};
