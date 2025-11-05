const mongoose = require('mongoose'); // ADD THIS IMPORT
const Schedule = require('../models/Schedule');

// Mark/Unmark date for element
exports.toggleMarkedDate = async (req, res) => {
  try {
    const { elementId, date } = req.body;
    
    if (!elementId || !date) {
      return res.status(400).json({ error: 'Element ID and date are required' });
    }

    // Validate element ID format
    if (!mongoose.Types.ObjectId.isValid(elementId)) { // ADD VALIDATION
      return res.status(400).json({ error: 'Invalid element ID format' });
    }

    // Convert date to start of day in UTC
    const markedDate = new Date(date);
    markedDate.setUTCHours(0, 0, 0, 0);

    // Check if date already marked
    const existing = await Schedule.findOne({ elementId, markedDate });

    if (existing) {
      await Schedule.deleteOne({ _id: existing._id });
      return res.json({ action: 'removed', markedDate });
    } else {
      const newSchedule = new Schedule({ elementId, markedDate });
      await newSchedule.save();
      return res.status(201).json({ action: 'added', markedDate });
    }
  } catch (err) {
    console.error('Toggle schedule error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Get all marked dates for element
exports.getMarkedDates = async (req, res) => {
  try {
    const { elementId } = req.params;
    
    // ADD VALIDATION
    if (!mongoose.Types.ObjectId.isValid(elementId)) {
      return res.status(400).json({ error: 'Invalid element ID format' });
    }

    const schedules = await Schedule.find({ elementId }).select('markedDate -_id');
    const markedDates = schedules.map(s => s.markedDate.toISOString().split('T')[0]);
    
    res.json({ markedDates });
  } catch (err) {
    console.error('Get schedules error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Unmark a specific date
exports.unmarkDate = async (req, res) => {
  try {
    const { elementId, date } = req.body;
    
    if (!elementId || !date) {
      return res.status(400).json({ error: 'Element ID and date are required' });
    }

    if (!mongoose.Types.ObjectId.isValid(elementId)) {
      return res.status(400).json({ error: 'Invalid element ID format' });
    }

    // Convert date to start of day in UTC
    const markedDate = new Date(date);
    markedDate.setUTCHours(0, 0, 0, 0);

    const result = await Schedule.deleteOne({ elementId, markedDate });

    if (result.deletedCount === 0) {
      return res.status(404).json({ error: 'Date not marked' });
    }

    res.json({ message: 'Date unmarked successfully' });
  } catch (err) {
    console.error('Unmark date error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
};