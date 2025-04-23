const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth');
const taskRoutes = require('./routes/tasks');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors()); // Cho phép mọi nguồn (có thể cấu hình chi tiết hơn nếu cần)
app.use(express.json()); // Thay thế body-parser với express built-in
app.use(express.urlencoded({ extended: true })); // Cho phép phân tích dữ liệu URL-encoded

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/tasks', taskRoutes);

// Xử lý lỗi toàn cục
app.use((err, req, res, next) => {
  console.error(err.stack);  // Log lỗi
  res.status(500).json({ message: 'Đã xảy ra lỗi hệ thống', error: err.message });
});

app.listen(PORT, () => {
  console.log(`Server đang chạy trên port ${PORT}`);
});
