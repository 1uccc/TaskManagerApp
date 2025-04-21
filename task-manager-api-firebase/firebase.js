const admin = require('firebase-admin');
const serviceAccount = require('./taskmanager-39dfc-firebase-adminsdk-fbsvc-4bf0d1893c.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount), // Sử dụng file JSON tải về
});

const db = admin.firestore(); // Kết nối với Firestore

module.exports = { admin, db };
