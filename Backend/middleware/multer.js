const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, `${uniqueSuffix}-${file.originalname}`);
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png|gif/;
    const extname = filetypes.test(
      path.extname(file.originalname).toLowerCase().replace('.', '')
    );
    
    // Fix: Check both MIME type and extension
    const mimetype = filetypes.test(file.mimetype) || 
                    file.mimetype === 'application/octet-stream';
    
    if (mimetype && extname) {
      return cb(null, true);
    }
    
    // Log detailed error for debugging
    console.error('Invalid file type:', {
      originalname: file.originalname,
      mimetype: file.mimetype,
      ext: path.extname(file.originalname)
    });
    
    cb(new Error('Only images are allowed (jpeg, jpg, png, gif)'));
  }
});

module.exports = upload;