const Category = require("../models/Category");
const Element = require("../models/Element");
const fs = require("fs");
const path = require("path");

// Create new category
exports.createCategory = async (req, res) => {
  try {
    const { name } = req.body;
    
    // Validate input
    if (!name || !name.trim()) {
      return res.status(400).json({ msg: "Category name is required" });
    }
    
    if (!req.file) {
      return res.status(400).json({ msg: "Category image is required" });
    }

    const newCategory = new Category({
      name: name.trim(),
      image: `/uploads/${req.file.filename}`
    });

    await newCategory.save();

    res.status(201).json({
      _id: newCategory._id,
      name: newCategory.name,
      image: newCategory.image,
      createdAt: newCategory.createdAt
    });
  } catch (err) {
    console.error("Create category error:", err.message);
    
    // Handle duplicate name error
    if (err.code === 11000) {
      return res.status(400).json({ msg: "Category name already exists" });
    }
    
    res.status(500).json({ msg: "Server error", error: err.message });
  }
};

// Get all categories
exports.getCategories = async (req, res) => {
  try {
    const categories = await Category.find().sort({ createdAt: -1 });
    res.json(categories);
  } catch (err) {
    console.error("Get categories error:", err.message);
    res.status(500).send("Server error");
  }
};

// Update category
exports.updateCategory = async (req, res) => {
  try {
    const { name } = req.body;
    const category = await Category.findById(req.params.id);
    
    if (!category) {
      return res.status(404).json({ msg: "Category not found" });
    }

    // Delete old image if updating with new one
    if (req.file) {
      const oldImagePath = path.join(__dirname, "..", category.image);
      if (fs.existsSync(oldImagePath)) {
        fs.unlinkSync(oldImagePath);
      }
      category.image = `/uploads/${req.file.filename}`;
    }

    if (name) category.name = name;
    
    await category.save();
    
    res.json({
      _id: category._id,
      name: category.name,
      image: category.image
    });
  } catch (err) {
    console.error("Update category error:", err.message);
    res.status(500).send("Server error");
  }
};

// Delete category
// Update deleteCategory function
exports.deleteCategory = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);
    
    if (!category) {
      return res.status(404).json({ msg: "Category not found" });
    }

    // First, delete all elements in this category
    const elements = await Element.find({ category: req.params.id });
    for (const element of elements) {
      const elementImagePath = path.join(__dirname, "..", element.image);
      if (fs.existsSync(elementImagePath)) {
        fs.unlinkSync(elementImagePath);
      }
      // Use deleteOne() here too
      await Element.deleteOne({ _id: element._id });
    }

    // Then delete category image
    const imagePath = path.join(__dirname, "..", category.image);
    if (fs.existsSync(imagePath)) {
      fs.unlinkSync(imagePath);
    }

    // Use deleteOne() for category
    await Category.deleteOne({ _id: req.params.id });
    
    res.json({ msg: "Category and its elements deleted successfully" });
  } catch (err) {
    console.error("Delete category error:", err.message);
    
    if (err.name === 'CastError') {
      return res.status(400).json({ msg: "Invalid category ID" });
    }
    
    res.status(500).json({ 
      msg: "Server error", 
      error: err.message,
      stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
    });
  }
};