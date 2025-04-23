const admin = require('firebase-admin');
const serviceAccount = require('./taskmanager-39dfc-firebase-adminsdk-fbsvc-c708fb3a76.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'taskmanager-39dfc.appspot.com',
});

const db = admin.firestore();
const storage = admin.storage().bucket(); // Lấy bucket đúng cách

module.exports = { admin, db, storage };
