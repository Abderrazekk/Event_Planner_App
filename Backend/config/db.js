const mongoose = require('mongoose');
const colors = require('colors');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log(`✅ MongoDB Connected: ${conn.connection.host}`.green.bold);
  } catch (err) {
    console.error(`❌ MongoDB Connection Error: ${err.message}`.red.bold);
    process.exit(1);
  }
};

module.exports = connectDB;