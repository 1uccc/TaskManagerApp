const { db } = require('../firebase');

const taskCollection = db.collection('tasks');

// Hàm tạo task
async function createTask({ title, description, status, priority, dueDate, createdAt, updatedAt, createdBy, assignedTo, category, attachments, completed }) {
  try {
    const taskRef = await taskCollection.add({
      title,
      description,
      status,
      priority,
      dueDate,
      createdAt,
      updatedAt,
      createdBy,
      assignedTo,
      category,
      attachments,
      completed,
    });
    return taskRef.id; // Trả về ID của công việc đã tạo
  } catch (error) {
    console.error('Lỗi khi tạo công việc:', error);
    throw new Error('Không thể tạo công việc');
  }
}

// Hàm lấy danh sách task
async function getTasks() {
  try {
    const tasksSnapshot = await taskCollection.get();
    const tasks = tasksSnapshot.docs.map(doc => doc.data());
    return tasks;
  } catch (error) {
    console.error('Lỗi khi lấy danh sách công việc:', error);
    throw new Error('Không thể lấy danh sách công việc');
  }
}

module.exports = { createTask, getTasks };
