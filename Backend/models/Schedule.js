const mongoose = require('mongoose');

const scheduleSchema = new mongoose.Schema({
  elementId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Element',
    required: true
  },
  markedDate: {
    type: Date,
    required: true,
    index: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Compound index for efficient queries
scheduleSchema.index({ elementId: 1, markedDate: 1 }, { unique: true });

module.exports = mongoose.model('Schedule', scheduleSchema);