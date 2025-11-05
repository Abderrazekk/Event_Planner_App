const jwt = require("jsonwebtoken");
const User = require("../models/User");
const Admin = require("../models/AdminModel");

const auth = async (req, res, next) => {
  try {
    const token = req.header("Authorization").replace("Bearer ", "");
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Check if user is in User collection
    let user = await User.findOne({ _id: decoded.id });
    
    // If not found in User collection, check Admin collection
    if (!user) {
      user = await Admin.findOne({ _id: decoded.id });
    }

    if (!user) {
      throw new Error();
    }

    req.user = user;
    req.token = token;
    next();
  } catch (err) {
    res.status(401).json({ msg: "Please authenticate" });
  }
};

module.exports = auth;