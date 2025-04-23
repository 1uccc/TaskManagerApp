import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'task_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Chưa đăng nhập");
    }
    return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trang chủ"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: "Đăng xuất",
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Không thể tải thông tin người dùng"));
          }

          final data = snapshot.data!.data()!;
          final username = data['username'] ?? 'Người dùng';
          final email = data['email'] ?? 'Không có email';
          final avatar = data['avatar'];

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (avatar != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(avatar),
                    radius: 40,
                  ),
                SizedBox(height: 12),
                Text(
                  "Xin chào $username",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 6),
                Text(
                  email,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TaskListScreen()),
                    );
                  },
                  child: Text("Xem danh sách công việc"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
