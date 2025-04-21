import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class TaskAPIService {
  final String _baseUrl = 'http://10.0.2.2:5000/api/tasks';

  // Hàm lấy token từ Firebase
  Future<String?> _getToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? token = await user.getIdToken();
      return token;
    }
    return null;
  }

  // Lấy tất cả công việc
  Future<List<Map<String, dynamic>>> getAllTasks() async {
    String? token = await _getToken();
    print("Token: $token");  // In token để kiểm tra

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    print("Response status: ${response.statusCode}");  // In mã trạng thái của phản hồi
    print("Response body: ${response.body}");  // In nội dung phản hồi

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Lỗi khi tải danh sách công việc');
    }
  }

  // Lấy công việc theo id
  Future<Map<String, dynamic>> getTaskById(String id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/$id'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Không tìm thấy công việc');
    }
  }

  // Cập nhật công việc
  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    String? token = await _getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Cập nhật thất bại');
    }
  }

  // Xóa công việc
  Future<void> deleteTask(String id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    if (response.statusCode != 200) {
      throw Exception('Xóa thất bại');
    }
  }
}
