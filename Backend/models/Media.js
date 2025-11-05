const mongoose = require('mongoose');

const mediaSchema = new mongoose.Schema({
  elementId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Element',
    required: true
  },
  filename: {
    type: String,
    required: true
  },
  originalName: {
    type: String,
    required: true
  },
  path: {
    type: String,
    required: true
  },
  type: {
    type: String,
    enum: ['photo', 'video'],
    required: true
  },
  uploadedAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Media', mediaSchema);