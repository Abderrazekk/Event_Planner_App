// server.js
require("dotenv").config();
const express = require("express");
const connectDB = require("./config/db");
const authRoutes = require("./routes/authRoutes");
const categoryRoutes = require("./routes/categoryRoutes");
const elementRoutes = require("./routes/elementRoutes");
const scheduleRoutes = require("./routes/scheduleRoutes");
const mediaRoutes = require("./routes/mediaRoutes");
const recommendationRoutes = require("./routes/recommendationRoutes");
const cors = require("cors");
const colors = require("colors"); // Add colors package
const Admin = require("./models/AdminModel"); // Import the new Admin model

const app = express();

console.log("🚀 Starting Wedding Planner Backend...".yellow.bold);

// Connect to database
console.log("🔌 Attempting to connect to MongoDB...".magenta);
connectDB();

// Initialize admin user
Admin.initializeAdmin(); // Use the static method from Admin model

// Middleware
app.use(cors());
app.use(express.json());
app.use("/uploads", express.static("uploads"));
console.log("🧩 Middleware initialized".green);

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/elements", elementRoutes);
app.use("/api/schedules", scheduleRoutes);
app.use("/api/media", mediaRoutes);
app.use("/api/recommendations", recommendationRoutes);

const PORT = process.env.PORT || 5000;

app.listen(PORT, "0.0.0.0", () => {
  console.log("\n" + "=".repeat(50).green);
  console.log(`✅ Server running on port ${PORT}`.bold.green);
  console.log(`🌐 Access at: http://localhost:${PORT}`.underline.cyan);
  console.log("=".repeat(50).green);

  console.log("\n📋 Available Endpoints:".bold);
  console.log("🔐 Authentication:".yellow);
  console.log(`   POST   http://localhost:${PORT}/api/auth/register`.cyan);
  console.log(`   POST   http://localhost:${PORT}/api/auth/login`.cyan);
  console.log(`   POST   http://localhost:${PORT}/api/auth/admin-login`.cyan); // Added admin login
  console.log(`   GET    http://localhost:${PORT}/api/auth/user`.cyan);

  console.log("\n💡 Admin Credentials:".bold);
  console.log("   Email: admin@gmail.com".cyan);
  console.log("   Password: admin1".cyan);

  console.log("\n💡 Tips:".bold);
  console.log("   - Use Postman to test endpoints".dim);
  console.log("   - Press Ctrl+C to stop the server".dim);
  console.log("\n🚀 Server is ready to handle requests!".bold.green);
});
