const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  image: {
    type: String,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

categorySchema.pre('deleteOne', { document: true, query: false }, async function(next) {
  try {
    // Delete all elements in this category
    await this.model('Element').deleteMany({ category: this._id });
    next();
  } catch (err) {
    next(err);
  }
});

module.exports = mongoose.model('Category', categorySchema);