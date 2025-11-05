const Element = require("../models/Element");

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

// Get all recommended elements
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