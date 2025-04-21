const { admin } = require('../firebase');

async function authenticate(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1]; // Lấy token từ header
  if (!token) {
    return res.status(401).json({ message: 'Không tìm thấy token xác thực' });
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken; // Gắn thông tin user vào request
    next(); // Tiếp tục đến route tiếp theo
  } catch (error) {
    return res.status(401).json({ message: 'Token không hợp lệ' });
  }
}

module.exports = { authenticate };
