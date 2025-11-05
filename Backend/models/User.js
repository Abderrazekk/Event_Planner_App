const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
  },
  phone: {
    type: String,
    required: true,
  },
  profileImage: {
    type: String,
    default: "/uploads/default-avatar.png",
  },
  password: {
    type: String,
    required: true,
  },
  role: {
    type: String,
    default: "client",
    immutable: true, // Prevents changing the role
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

userSchema.pre("save", async function (next) {
  // Only hash the password if it's modified (or new)
  if (!this.isModified("password")) return next();

  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (err) {
    next(err);
  }
});

// Add this after the existing pre-save hook
userSchema.pre("save", async function (next) {
  // Prevent creating multiple admins
  if (this.role === "admin") {
    const existingAdmin = await this.constructor.findOne({ role: "admin" });

    if (existingAdmin && !existingAdmin._id.equals(this._id)) {
      const error = new Error("Only one admin user allowed");
      return next(error);
    }
  }
  next();
});

userSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model("User", userSchema);
