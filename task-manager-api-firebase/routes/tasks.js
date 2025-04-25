const express = require('express');
const multer = require('multer');
const { authenticate } = require('../middleware/auth');
const { db, admin } = require('../firebase');  
const dbx = require('../utils/dropbox');       

const router = express.Router();
const taskCollection = db.collection('tasks');
const usersCollection = db.collection('users');

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, 
});

// Tạo task
router.post('/create', authenticate, upload.single('attachment'), async (req, res) => {
  let { title, description, status, priority, dueDate, category, completed, assignedTo } = req.body;
  const { uid } = req.user;
  const createdAt = new Date();
  const updatedAt = new Date();
  const attachment = req.file;
  

  priority = parseInt(priority);


  // Chuyển đổi completed thành boolean
  completed = completed === 'true';

  // Kiểm tra người dùng được giao công việc
  if (assignedTo) {
    const userDoc = await usersCollection.doc(assignedTo).get();
    if (!userDoc.exists) {
      return res.status(400).json({ message: 'Người dùng được giao không hợp lệ' });
    }
  }

  let attachmentUrl = null;
  if (attachment) {
    const fileName = `/task_attachments/${Date.now()}_${attachment.originalname}`;

    try {
      // Upload file lên Dropbox
      const uploadResult = await dbx.filesUpload({
        path: fileName,
        contents: attachment.buffer,
        mode: 'add',
        autorename: true,
        mute: true,
      });

      // Tạo link chia sẻ công khai
      const sharedLink = await dbx.sharingCreateSharedLinkWithSettings({
        path: uploadResult.result.path_lower,
      });

      // Chuyển link sang dạng raw
      attachmentUrl = sharedLink.result.url.replace('?dl=0', '?raw=1');
    } catch (error) {
      console.error('Lỗi khi tải tệp lên Dropbox:', error);
      return res.status(500).json({
        message: 'Không thể tải tệp đính kèm',
        error: error.response ? error.response.data : error.message,
      });
    }
  }

  try {
    const taskRef = await taskCollection.add({
      title,
      description,
      status,
      priority,
      dueDate,
      createdAt,
      updatedAt,
      createdBy: uid,
      assignedTo: assignedTo || null,
      category,
      attachments: attachmentUrl ? [attachmentUrl] : [],
      completed,
    });

    res.status(201).json({ message: 'Công việc đã được tạo', taskId: taskRef.id });
  } catch (error) {
    console.error('Lỗi khi tạo công việc:', error);
    res.status(400).json({ message: 'Lỗi khi tạo công việc', error: error.message });
  }
});
// Xóa task
router.delete('/:id', authenticate, async (req, res) => {
  const taskId = req.params.id;

  try {
    const taskDoc = await taskCollection.doc(taskId).get();

    if (!taskDoc.exists) {
      return res.status(404).json({ message: 'Không tìm thấy công việc' });
    }

    // Optional: kiểm tra quyền xóa - chỉ người tạo mới được xóa
    const { uid } = req.user;
    if (taskDoc.data().createdBy !== uid) {
      return res.status(403).json({ message: 'Bạn không có quyền xóa công việc này' });
    }

    await taskCollection.doc(taskId).delete();
    res.status(200).json({ message: 'Đã xóa công việc' });
  } catch (error) {
    console.error('Lỗi khi xóa công việc:', error);
    res.status(500).json({ message: 'Lỗi khi xóa công việc', error: error.message });
  }
});
// Cập nhật task
router.put('/:id', authenticate, upload.single('attachment'), async (req, res) => {
  const { id } = req.params;
  const { uid } = req.user;
  let { title, description, status, priority, dueDate, category, completed, assignedTo } = req.body;
  const updatedAt = new Date();
  const attachment = req.file;

  priority = parseInt(priority);
  completed = completed === 'true';

  try {
    const taskDoc = await taskCollection.doc(id).get();

    if (!taskDoc.exists) {
      return res.status(404).json({ message: 'Công việc không tồn tại' });
    }

    const taskData = taskDoc.data();


    // Kiểm tra user được giao nếu có
    if (assignedTo) {
      const userDoc = await usersCollection.doc(assignedTo).get();
      if (!userDoc.exists) {
        return res.status(400).json({ message: 'Người dùng được giao không hợp lệ' });
      }
    }

    let attachmentUrl = null;
    if (attachment) {
      const fileName = `/task_attachments/${Date.now()}_${attachment.originalname}`;

      try {
        const uploadResult = await dbx.filesUpload({
          path: fileName,
          contents: attachment.buffer,
          mode: 'add',
          autorename: true,
          mute: true,
        });

        const sharedLink = await dbx.sharingCreateSharedLinkWithSettings({
          path: uploadResult.result.path_lower,
        });

        attachmentUrl = sharedLink.result.url.replace('?dl=0', '?raw=1');
      } catch (err) {
        console.error('Lỗi khi upload tệp:', err);
        return res.status(500).json({ message: 'Không thể tải tệp đính kèm' });
      }
    }

    const updatedData = {
      title,
      description,
      status,
      priority,
      dueDate,
      category,
      completed,
      updatedAt,
      assignedTo: assignedTo || null,
    };

    if (attachmentUrl) {
      updatedData.attachments = [attachmentUrl];
    }

    await taskCollection.doc(id).update(updatedData);

    res.status(200).json({ message: 'Đã cập nhật công việc' });
  } catch (error) {
    console.error('Lỗi khi cập nhật công việc:', error);
    res.status(500).json({ message: 'Lỗi khi cập nhật công việc', error: error.message });
  }
});

// Cập nhật trạng thái task
router.patch('/:id/status', authenticate, async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  try {
    const taskDoc = await taskCollection.doc(id).get();

    if (!taskDoc.exists) {
      return res.status(404).json({ message: 'Công việc không tồn tại' });
    }

    const taskData = taskDoc.data();


    await taskCollection.doc(id).update({ status });

    res.status(200).json({ message: 'Cập nhật trạng thái công việc thành công' });
  } catch (error) {
    console.error('Lỗi khi cập nhật trạng thái công việc:', error);
    res.status(500).json({ message: 'Lỗi khi cập nhật trạng thái', error: error.message });
  }
});


// Lấy danh sách công việc
router.get('/', authenticate, async (req, res) => {
  const { uid } = req.user;

  try {
    const createdTasksSnapshot = await taskCollection.where('createdBy', '==', uid).get();
    const assignedTasksSnapshot = await taskCollection.where('assignedTo', '==', uid).get();

    const tasks = [
      ...createdTasksSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })),
      ...assignedTasksSnapshot.docs
        .filter(doc => !createdTasksSnapshot.docs.some(c => c.id === doc.id))
        .map(doc => ({ id: doc.id, ...doc.data() })),
    ];

    res.status(200).json(tasks);
  } catch (error) {
    console.error('Lỗi khi lấy danh sách công việc:', error);
    res.status(400).json({ message: 'Lỗi khi lấy danh sách công việc', error: error.message });
  }
});

module.exports = router;
