const express = require('express');
const { createUser } = require('../models/userModel');
const admin = require('firebase-admin');
const router = express.Router();

// API Đăng ký người dùng mới
router.post('/register', async (req, res) => {
  const { username, email, password } = req.body;
  try {
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: username,
    });

    const uid = userRecord.uid;
    const createdAt = new Date();
    const lastActive = createdAt;

    await createUser({ uid, username, email, avatar: '', createdAt, lastActive });

    res.status(201).json({ message: 'Tạo người dùng thành công', uid });
  } catch (error) {
    res.status(400).json({ message: 'Lỗi đăng ký', error: error.message });
  }
});

// API Đăng nhập
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const userRecord = await admin.auth().getUserByEmail(email);
    // Kiểm tra mật khẩu với Firebase Auth (hoặc bạn có thể dùng Firebase Authentication SDK trên client)
    res.status(200).json({ message: 'Đăng nhập thành công', uid: userRecord.uid });
  } catch (error) {
    res.status(400).json({ message: 'Lỗi đăng nhập', error: error.message });
  }
});

module.exports = router;
