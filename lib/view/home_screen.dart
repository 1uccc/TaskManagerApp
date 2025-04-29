import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'task_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Thêm màu gradient
  final Color GradientStart = const Color(0xff66fb9a);
  final Color GradientEnd = const Color(0xff002d88);

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
        backgroundColor: const Color(0xff5de797),
        title: const Text(
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
          "Trang chủ",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Đăng xuất",
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Container(
        // nền gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [GradientStart, GradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!.exists) {
              return const Center(
                child: Text("Không thể tải thông tin người dùng"),
              );
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
                  const SizedBox(height: 12),
                  Text(
                    "Xin chào $username",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(email, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TaskListScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      "Xem danh sách công việc",
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
