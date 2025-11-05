// models/AdminModel.js
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const adminSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    default: "Admin"
  },
  email: {
    type: String,
    required: true,
    unique: true,
    default: "admin@gmail.com"
  },
  phone: {
    type: String,
    required: true,
    default: "000-000-0000"
  },
  profileImage: {
    type: String,
    default: "/uploads/default-admin.png",
  },
  password: {
    type: String,
    required: true,
    default: "admin1"
  },
  role: {
    type: String,
    default: "admin",
    immutable: true // Prevents changing the role
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

adminSchema.pre("save", async function (next) {
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

adminSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Static method to initialize admin
adminSchema.statics.initializeAdmin = async function () {
  try {
    const existingAdmin = await this.findOne({ role: 'admin' });
    
    if (!existingAdmin) {
      // Create admin user
      await this.create({
        name: 'Admin',
        email: 'admin@gmail.com',
        password: 'admin1', // Plain text password - will be hashed by pre-save hook
        phone: '71852963',
        role: 'admin',
        profileImage: '/uploads/default-admin.png'
      });
      
      console.log('👑 Admin user created successfully');
    }
  } catch (error) {
    console.error('Error initializing admin:', error.message);
  }
};

module.exports = mongoose.model("Admin", adminSchema);