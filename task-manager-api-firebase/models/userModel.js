const { db } = require('../firebase');

const userCollection = db.collection('users');

// Hàm tạo user
async function createUser({ uid, username, email, avatar, createdAt, lastActive }) {
  try {
    await userCollection.doc(uid).set({
      id: uid,
      username,
      email,
      avatar,
      createdAt,
      lastActive,
    });
  } catch (error) {
    console.error('Lỗi khi tạo người dùng:', error);
    throw new Error('Không thể tạo người dùng');
  }
}

// Hàm lấy thông tin người dùng theo UID
async function getUser(uid) {
  try {
    const userRef = await userCollection.doc(uid).get();
    if (!userRef.exists) {
      throw new Error('Người dùng không tồn tại');
    }
    return userRef.data();
  } catch (error) {
    console.error('Lỗi khi lấy người dùng:', error);
    throw new Error('Không thể lấy thông tin người dùng');
  }
}

module.exports = { createUser, getUser };
