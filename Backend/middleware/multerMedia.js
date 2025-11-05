const multer = require('multer');
const path = require('path');

// Create uploads/media directory if it doesn't exist
const fs = require('fs');
const dir = './uploads/media';
if (!fs.existsSync(dir)) {
  fs.mkdirSync(dir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/media/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, `${uniqueSuffix}-${file.originalname}`);
  }
});

const upload = multer({
  storage: storage,
  limits: { 
    fileSize: 50 * 1024 * 1024 // 50MB limit for videos
  },
  fileFilter: (req, file, cb) => {
    // Allow both images and videos
    const filetypes = /jpeg|jpg|png|gif|mp4|mov|avi|mkv/;
    const extname = filetypes.test(
      path.extname(file.originalname).toLowerCase().replace('.', '')
    );
    
    const mimetype = filetypes.test(file.mimetype) || 
                    file.mimetype === 'application/octet-stream' ||
                    file.mimetype.startsWith('video/');
    
    if (mimetype && extname) {
      return cb(null, true);
    }
    
    console.error('Invalid file type:', {
      originalname: file.originalname,
      mimetype: file.mimetype,
      ext: path.extname(file.originalname)
    });
    
    cb(new Error('Only images and videos are allowed'));
  }
});

module.exports = upload;