const express = require('express');
const { authenticate } = require('../middleware/auth'); // middleware xác thực
const { createTask, getTasks } = require('../models/taskModel'); // các hàm tạo và lấy công việc
const router = express.Router();

// API Tạo công việc
router.post('/create', authenticate, async (req, res) => { // Đây là hàm handler hợp lệ
  const { title, description, status, priority, dueDate, category, attachments, completed } = req.body;
  const { uid } = req.user;
  const createdAt = new Date();
  const updatedAt = new Date();

  try {
    const taskId = await createTask({
      title,
      description,
      status,
      priority,
      dueDate,
      createdAt,
      updatedAt,
      createdBy: uid,
      assignedTo: null, // Chưa gán cho ai
      category,
      attachments,
      completed,
    });

    res.status(201).json({ message: 'Công việc đã được tạo', taskId });
  } catch (error) {
    res.status(400).json({ message: 'Lỗi khi tạo công việc', error: error.message });
  }
});

// API Lấy danh sách công việc
router.get('/', authenticate, async (req, res) => { // Đây là hàm handler hợp lệ
  try {
    const tasks = await getTasks();
    res.status(200).json(tasks);
  } catch (error) {
    res.status(400).json({ message: 'Lỗi khi lấy danh sách công việc', error: error.message });
  }
});

module.exports = router;
