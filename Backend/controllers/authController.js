const User = require("../models/User");
const Admin = require('../models/AdminModel');
const generateToken = require("../config/jwt");
const fs = require("fs");
const path = require("path");

// Register user
exports.registerUser = async (req, res) => {
  try {
    const { name, email, password, phone } = req.body;

    // Check if email exists in either User or Admin collection
    let user = await User.findOne({ email });
    let admin = await Admin.findOne({ email });
    
    if (user || admin) {
      return res.status(400).json({ msg: "User already exists" });
    }

    // Handle file upload
    let profileImage = "/uploads/default-avatar.png";
    if (req.file) {
      profileImage = `/uploads/${req.file.filename}`;
    }

    user = new User({
      name,
      email,
      password,
      phone,
      profileImage,
      role: "client",
    });

    await user.save();

    res.json({
      _id: user.id,
      name: user.name,
      email: user.email,
      profileImage: user.profileImage,
      token: generateToken(user._id),
    });
  } catch (err) {
    console.error("Registration error:", err.message);

    // Handle multer errors specifically
    if (err.name === "MulterError") {
      return res.status(400).json({ msg: err.message });
    }

    res.status(500).send("Server error");
  }
};

// Login user
exports.loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    // First check if it's a regular user
    let user = await User.findOne({ email });
    let isAdmin = false;

    // If not found in User collection, check Admin collection
    if (!user) {
      user = await Admin.findOne({ email });
      isAdmin = true;
    }

    if (!user) {
      return res.status(400).json({ msg: "Invalid credentials" });
    }

    const isMatch = await user.matchPassword(password);

    if (!isMatch) {
      return res.status(400).json({ msg: "Invalid credentials" });
    }

    res.json({
      _id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      isAdmin: isAdmin,
      token: generateToken(user._id),
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
};

// Update profile image
exports.updateProfileImage = async (req, res) => {
  try {
    // Check if user is in User collection
    let user = await User.findById(req.user.id);
    let isAdmin = false;

    // If not found in User collection, check Admin collection
    if (!user) {
      user = await Admin.findById(req.user.id);
      isAdmin = true;
    }

    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    // Remove old image if it's not the default
    if (req.file) {
      const defaultImage = isAdmin ? "/uploads/default-admin.png" : "/uploads/default-avatar.png";
      if (user.profileImage && user.profileImage !== defaultImage) {
        const oldImagePath = path.join(__dirname, "..", user.profileImage);
        if (fs.existsSync(oldImagePath)) {
          fs.unlinkSync(oldImagePath);
        }
      }
      user.profileImage = `/uploads/${req.file.filename}`;
      await user.save();
    }

    res.json({
      profileImage: user.profileImage,
      msg: "Profile image updated successfully",
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
};

// Get user profile
exports.getUserProfile = async (req, res) => {
  try {
    // Check if user is in User collection
    let user = await User.findById(req.user.id).select("-password");
    
    // If not found in User collection, check Admin collection
    if (!user) {
      user = await Admin.findById(req.user.id).select("-password");
    }

    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    res.json(user);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
};

// Admin login
exports.adminLogin = async (req, res) => {
  const { email, password } = req.body;

  try {
    // Check Admin collection only for admin login
    const admin = await Admin.findOne({ email });

    if (!admin) {
      return res.status(401).json({ msg: "Admin access denied" });
    }

    const isMatch = await admin.matchPassword(password);

    if (!isMatch) {
      return res.status(401).json({ msg: "Invalid credentials" });
    }

    res.json({
      _id: admin.id,
      name: admin.name,
      email: admin.email,
      role: admin.role,
      isAdmin: true,
      token: generateToken(admin._id),
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
};

// Change user password
exports.changePasswordWithoutCurrent = async (req, res) => {
  try {
    const { newPassword } = req.body;
    
    // Validate input
    if (!newPassword) {
      return res.status(400).json({ msg: "New password is required" });
    }
    
    if (newPassword.length < 6) {
      return res.status(400).json({ msg: "Password must be at least 6 characters" });
    }

    // Check if user is in User collection
    let user = await User.findById(req.user.id);
    
    // If not found in User collection, check Admin collection
    if (!user) {
      user = await Admin.findById(req.user.id);
    }

    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    // Update password
    user.password = newPassword;
    await user.save();

    res.json({ msg: "Password updated successfully" });
  } catch (err) {
    console.error("Password change error:", err.message);
    res.status(500).json({ msg: "Server error" });
  }
};

// Get user registration statistics (last 12 months)
exports.getUserStats = async (req, res) => {
  try {
    const twelveMonthsAgo = new Date();
    twelveMonthsAgo.setMonth(twelveMonthsAgo.getMonth() - 12);

    const userStats = await User.aggregate([
      {
        $match: {
          createdAt: { $gte: twelveMonthsAgo }
        }
      },
      {
        $group: {
          _id: {
            year: { $year: "$createdAt" },
            month: { $month: "$createdAt" }
          },
          count: { $sum: 1 }
        }
      },
      {
        $sort: { "_id.year": 1, "_id.month": 1 }
      }
    ]);

    // Format the data to include all 12 months, even if count is 0
    const months = [];
    for (let i = 0; i < 12; i++) {
      const date = new Date();
      date.setMonth(date.getMonth() - i);
      const year = date.getFullYear();
      const month = date.getMonth() + 1;

      const stat = userStats.find(s => s._id.year === year && s._id.month === month);
      months.unshift({
        year: year,
        month: month,
        count: stat ? stat.count : 0
      });
    }

    res.json(months);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};