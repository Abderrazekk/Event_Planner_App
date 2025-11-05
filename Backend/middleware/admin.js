const User = require("../models/User");
const Admin = require("../models/AdminModel");

module.exports = async (req, res, next) => {
  try {
    // Check if user is in User collection
    let user = await User.findById(req.user.id);
    
    // If not found in User collection, check Admin collection
    if (!user) {
      user = await Admin.findById(req.user.id);
    }

    if (user && user.role === 'admin') {
      next();
    } else {
      res.status(403).json({ msg: 'Admin access required' });
    }
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
};